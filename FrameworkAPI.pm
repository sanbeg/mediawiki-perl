package FrameworkAPI;
use Carp;
use MediaWiki::API;
use strict;

sub new ($;$$) {
    my ($class,$site,$path)=@_;
    my $mw = MediaWiki::API->new();
    if (defined $site) {
	$path = 'w' unless defined $path;
	$mw->{config}->{api_url} = "http://$site/$path/api.php";
    }
    #$mw->{ua}->cookie_jar({file=>"$ENV{HOME}/.cookies.txt", autosave=>1});
    bless {0=>$mw, write_prefix=>''}, $class;
}

sub cookie_jar( $$ ) {
    #temporary method for persistent login.
    my $self = shift;
    my $file = shift;
    $self->{0}{ua}->cookie_jar($file, autosave=>1);
}

sub login ($$$) {
    my ($self,$user,$pass) = @_;
    my $mw = $self->{0};

    my $state = $mw->api({ action=>'query', meta=>'userinfo', });
    
    if (
	 ! exists $state->{query}{userinfo}{anon}
	and
	$state->{query}{userinfo}{name} eq $user
	){ 
	warn "already logged in as $user";
    } else {
	$mw->login( { lgname => $user, lgpassword => $pass } )
	    or croak $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    }
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
    
    die "goodbye cruel world";

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
	my ($class,$api,$title) = @_;
	my $page = $api->{0}->get_page({title=>$title});
	bless [$api,$page], $class;
    }

    sub get_text( $$ ) {
	return $_[0]->[1]->{'*'};
    };

    sub edit( $$$ ) {
	my ($self,$text,$summary) = @_;
	my $mw = $self->[0];
	my $page = $self->[1];
	my $p = $mw->{write_prefix};

	my %qh = (
	    action=>'edit', 
	    bot=>1,
	    title=>($p.$page->{title}),
	    text=>$text,
	    summary=>$summary,
	    );
	$qh{basetimestamp}=$page->{timestamp} if $p eq '';

	eval {
	    warn "edit $qh{title}";
 	    $mw->{0}->edit(\%qh) 
 		or croak $mw->{error}->{code} . ': ' . $mw->{error}->{details};
	};
	
	Carp::croak "Edit failed: $@" if $@;
    };
    
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
