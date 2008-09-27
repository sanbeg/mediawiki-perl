package FrameworkAPI;
use Carp;
use MediaWiki::API;

sub new ($;$$) {
    my ($class,$site,$path)=@_;
    my $mw = MediaWiki::API->new();
    if (defined $site) {
	$path = 'w' unless defined $path;
	$mw->{config}->{api_url} = "http://$site/$path/api.php";
    }
    bless {0=>$mw, write_prefix=>''}, $class;
}

sub login ($$$) {
    my ($self,$user,$pass) = @_;
    my $mw = $self->{0};
    $mw->login( { lgname => $user, lgpassword => $pass } )
    or croak $mw->{error}->{code} . ': ' . $mw->{error}->{details};
}

sub get_text( $$ ) {
    my ($self,$title) = @_;
    my $page = $self->{0}->get_page({title=>$title});
    return $page->{'*'};
    #FIXME - store $page->{timestamp}, to pass back in
    # edit (basetimestamp=>$ts,..)

};

sub edit( $$$ ) {
    my ($self,$title,$text,$summary) = @_;
    my $mw = $self->{0};

    $mw->edit({
	action=>'edit', bot=>1,
	title=>$title,
	text=>$text,
	summary=>$summary,
	}) or croak $mw->{error}->{code} . ': ' . $mw->{error}->{details};
}

{
    package FrameworkAPI::Page;

    sub new ($$$) {
	my ($class,$self,$title) = @_;
	my $page = $self->{0}->get_page({title=>$title});
	bless [$self,$page], $class;
    }

    sub get_text( $$ ) {
	return $_[0]->[1]->{'*'};
    };

    sub edit( $$$ ) {
	my ($self,$text,$summary) = @_;
	my $mw = $self->[0];
	my $page = $self->[1];
	my $p = $mw->{write_prefix};

	$mw->edit({
	    action=>'edit', bot=>1,
	    title=>$page->{title},
	    text=>$p.$text,
	    basetimestamp=>$page->{timestamp},
	    summary=>$summary,
		  }) 
	    or croak $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    }
    
    sub exists {
	my ($self) = @_;
	return exists $self->[1]->{'*'};
    };

}


sub get_page( $$ ) {
    FrameworkAPI::Page->new(@_);
};
sub create_page( $$ ) {
    my $page = FrameworkAPI::Page->new(@_);
    croak "$_[1]: exists" if $page->exists;
    return $page;
};


1;
