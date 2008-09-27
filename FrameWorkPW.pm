package FrameWorkPW;
use Carp;
use Perlwikipedia;

sub new ($;$$) {
    my ($class,$site,$path)=@_;
    my $self = Perlwikipedia->new('Perl');
    if (defined($site)) {
	$self->set_wiki ($site, defined($path)?$path:'w');
    };
    bless [$self], $class;
};

sub login ($$$) {
    my $self = shift;
    my $wiki = $self->[0];
    $wiki->login(@_);
    croak "login failed? - $wiki->{errstr}" unless $wiki->{errstr} eq '';
}

sub get_text( $$ ) {
    my $self = shift;
    $self->[0]->get_text(@_);
};

sub edit {
    my $self = shift;
    $self->[0]->edit(@_);
};

{
    package FrameWorkPW::Page;

    sub new ( $$$ ) {
	#not much to do here
	my ($class,$self,$title) = @_;
	bless [$self,$title], $class;
    };
    
    sub edit {
	my $page = shift;
	$page->[0]->edit($page->[1], @_);
    };

}

1;
