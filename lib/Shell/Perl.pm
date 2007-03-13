
package Shell::Perl;

use 5;
use strict;
use warnings;

# $Id: Perl.pm 1131 2007-01-27 17:43:35Z me $

our $VERSION = '0.0009';

use base qw(Class::Accessor); # soon use base qw(Shell::Base);
Shell::Perl->mk_accessors(qw(out_type context package)); # XXX use_strict

use Term::ReadLine;
use Data::Dump ();
use Data::Dumper ();
use YAML ();

# out_type defaults to 'D';
# context defaults to 'list'
# package defaults to __PACKAGE__ . '::sandbox'
# XXX use_strict defaults to 0

sub new {
    my $self = shift;
    return $self->SUPER::new({ 
                           out_type => 'D', 
                           context => 'list', 
                           package => __PACKAGE__ . '::sandbox',
                           @_ });
}

sub _shell_name {
    require File::Basename;
    return File::Basename::basename($0);
}

sub print {
    shift;
    print @_;
}

sub out {
    my $self = shift;

    # XXX I want to improve this: preferably with an easy way to add dumpers
    if ($self->context eq 'scalar') {
        $self->print(Data::Dump::dump(shift), "\n") if $self->out_type eq 'D';
        $self->print(Data::Dumper::Dumper(shift)) if $self->out_type eq 'DD';
        $self->print(YAML::Dump(shift)) if $self->out_type eq 'Y';
    } else { # list
        $self->print(Data::Dump::dump(@_), "\n") if $self->out_type eq 'D';
        $self->print(Data::Dumper::Dumper(@_)) if $self->out_type eq 'DD';
        $self->print(YAML::Dump(@_)) if $self->out_type eq 'Y';
    }
}

sub set_out {
    my $self = shift;
    my $type = shift;
    if ($type =~ /^(DD|Data::Dumper)$/) {
        $self->out_type('DD');
    } elsif ($type =~ /^(Y|YAML)$/) {
        $self->out_type('Y');
    } elsif ($type =~ /^(D|Data::Dump)$/) {
        $self->out_type('D');
    } else {
        my $shell_name = _shell_name;
        warn "$shell_name: don't know what you're talking about\n";
    }
}

sub _ctx {
    my $context = shift;

    if ($context =~ /^(s|scalar|\$)$/i) {
        return 'scalar';
    } elsif ($context =~ /^(l|list|@)$/i) {
        return 'list';
    } elsif ($context =~ /^(v|void|_)$/i) {
        return 'void';
    } else {
        return undef;
    }
}

sub set_ctx {
    my $self    = shift;
    my $context = _ctx shift;

    if ($context) {
        $self->context($context);
    } else {
        my $shell_name = _shell_name;
        warn "$shell_name: don't know what you're talking about\n";
    }
}

use constant HELP =>
    <<'HELP';
Shell commands:           (begin with ':')
  :exit or :q(uit) - leave the shell
  :set out (D|DD|Y) - setup the output with Data::Dump, Data::Dumper or YAML
  :set ctx (scalar|list|void|s|l|v|$|@|_) - setup the eval context
  :reset - reset the environment
  :h(elp) - get this help screen

HELP

sub help {
    print HELP;
}

# :reset is a nice idea - but I wanted more like CPAN reload
# I retreated the current implementation of :reset
#    because %main:: is used as the evaluation package
#    and %main:: = () is too severe by now

sub reset {
    my $self = shift;
    my $package = $self->package;
    return if $package eq 'main'; # XXX don't reset %main::
    no strict 'refs';
    %{"${package}::"} = ();
    #%main:: = (); # this segfaults at my machine
}

sub prompt_title {
    my $self = shift;
    my $shell_name = _shell_name;
    my $sigil = { scalar => '$', list => '@', void => '' }->{$self->{context}};
    return "$shell_name $sigil> ";
}

sub run {
    my $self = shift;
    my $shell_name = _shell_name;
    my $term = Term::ReadLine->new($shell_name);
    my $prompt = "$shell_name > ";

    print "Welcome to the Perl shell. Type ':help' for more information\n\n";

    while (defined ($_ = $term->readline($self->prompt_title))) {

        # trim
        s/^\s+//g;
        s/\s+$//g;

        if (/^:/) { # shell commands
            last if /^:(exit|quit|q)/;
            $self->set_out($1) if /^:set out (\S+)/;
            $self->set_ctx($1) if /^:set ctx (\S+)/;
            $self->reset if /^:reset/;
            $self->help if /^:h(elp)?/;
            # unknown shell command ?!
            next;
        }

        my $context;
        $context = _ctx($1) if s/#(s|scalar|\$|l|list|\@|v|void|_)\z//;
        $context = $self->context unless $context;
        if ($context eq 'scalar') {
            my $out = $self->eval($_);
            if ($@) { warn "ERROR: $@"; next }
            $self->out($out);
        } elsif ($context eq 'list') {
            my @out = $self->eval($_);
            if ($@) { warn "ERROR: $@"; next }
            $self->out(@out);
        } elsif ($context eq 'void') {
            $self->eval($_);
            if ($@) { warn "ERROR: $@"; next }
        } else {
            # XXX ???
        }

    }
    #print "Bye.\n"; # XXX

}

# $shell->eval($exp)
sub eval {
    my $self = shift;
    my $exp = shift;
    my $package = $self->package;

    return eval <<CHUNK;
       package $package; # XXX
       no strict qw(vars subs);
       $exp
CHUNK
}


sub run_with_args {
    my $self = shift; #
    # XXX do something with @ARGV (GetOpt)
    my $shell = Shell::Perl->new();
    $shell->run;
}

1;

# OUTPUT Data::Dump, Data::Dumper, YAML, others
# document: use a different package when eval'ing 
# reset the environment
# implement shell commands (:quit, :set, :exit, etc.)
# how to implement array contexts?
#    IDEA:    command  ":set ctx scalar | list | void"
#             terminators "#s" "#l" "#v" "#$" #@ #_
# allow multiline entries. how?

##sub set {} # sets up the instance variables of the shell
##
##sub run {} # run the read-eval-print loop
##
##sub read {} # read a chunk
##
##sub readline {} # read a line
##
##sub eval {}
##
##sub print {}
##
##sub warn {}
##
##sub help { shift->print(HELP) }
##
##sub out { ? }

# svn:keywords Id
# svn:eol-style LF

__END__

=head1 NAME

Shell::Perl - A read-eval-loop in Perl 

=head1 SYNOPSYS

    use Shell::Perl;
    Shell::Perl->run_with_args;

=head1 DESCRIPTION

This is the implementation of a command-line interpreter for Perl. 
I wrote this because I was tired of using B<irb> when
needing a calculator with a real language within. Ah,
that and because it was damn easy to write it.

This module is the heart of the B<pirl> script provided with
B<Shell-Perl> distribution, along with this module.

=head2 EXAMPLE SESSION

    $ pirl
    Welcome to the Perl shell. Type ':help' for more information


    pirl @> 1+1
    2

    pirl @> use YAML qw(Load Dump);
    ()

    pirl @> $data = Load("--- { a: 1, b: [ 1, 2, 3] }\n");
    { a => 1, b => [1, 2, 3] }

    pirl @> $var = 'a 1 2 3'; $var =~ /(\w+) (\d+) (\d+)/
    ("a", 1, 2)

    pirl @> :q

=head2 COMMANDS

Most of the time, the shell reads Perl statements, evaluates them
and outputs the result.

There are a few commands (started by ':') that are handled
by the shell itself.

=over 4

=item :h(elp)

Handy for remembering what the shell commands are.

=item :q(uit)

Leave the shell. The Perl statement C<exit> will work too.

SYNONYMS: :exit

=item :set out (D|DD|Y)

Changes the dumper for the expression results used before
output. The current supported are:

=over 4

=item D

C<Data::Dump>, the default

=item DD

C<Data::Dumper>, the good and old core module

=item Y

C<YAML>

=back

=item :set ctx (scalar|list|void|s|l|v|$|@|_)

Changes the default context used to evaluate the entered expression.
The default is C<'list'>.

Intuitively, 'scalar', 's' and '$' are synonyms, just
like 'list', 'l', and '@' or 'void', 'v', '_'.

There is a nice way to override the default context in a given expression.
Just a '#' followed by one of 'scalar|list|void|s|l|v|$|@|_' at the end
of the expression.

    pirl @> $var = 'a 1 2 3'; $var =~ /(\w+) (\d+) (\d+)/
    ("a", 1, 2)

    pirl @> $var = 'a 1 2 3'; $var =~ /(\w+) (\d+) (\d+)/ #scalar
    1

=item :reset

Resets the environment, erasing the symbols created
at the current evaluation package. See the
section L<"ABOUT EVALUATION">.

=back

=head2 METHODS

Remember this is an alpha version, so the API may change
and that includes the methods documented here. So consider
this section as implementation notes for a while.

In later versions, some of these information may be promoted
to a public status. Others may be hidden or changed and
even disappear without further notice.

=over 4

=item B<new>

    $sh = Shell::Version->new;

The constructor.

=item B<run_with_args>

    Shell::Perl->run_with_args;

Starts the read-eval-print loop after (possibly) reading
options from C<@ARGV>. It is a class method.

=item B<run>

    $sh->run;

The same as C<run_with_args> but with no code for
interpreting command-line arguments. It is an instance method,
so that C<Shell::Perl->run_with_args> is kind of:

    Shell::Perl->new->run;

=item eval

    $answer = $sh->eval($exp);
    @answer = $sh->eval($exp);

Evaluates the user input given in C<$exp> as Perl code and returns
the result. That is the 'eval' part of the 
read-eval-print loop.

=item B<print>

    $sh->print(@args);

Prints a list of args at the output stream currently used
by the shell. (It is just STDOUT by now.)

=item B<out>

    $sh->out($answer);
    $sh->out(@answers);

That corresponds to the 'print' in the read-eval-print
loop. It outputs the evaluation result after passing it 
through the current dumper.

=item B<help>

    $sh->help;

Outputs the help as provided by the command ":help".

=item B<reset>

    $sh->reset;

Does nothing by now, but it will.

=item B<set_ctx>

    $sh->set_ctx($context);

Assigns to the current shell context. The argument
must be one of C< ( 'scalar', 'list', 'void',
's', 'l', 'v', '$', '@', '_' ) >.

=item B<set_out>

    $sh->set_out($dumper);

Changes the current dumper used for printing
the evaluation results. Actually must be one of
"D" (for Data::Dump), "DD" (for Data::Dumper)
or "Y" (for YAML).

=item B<prompt_title>

    $prompt = $sh->prompt_title;

Returns the current prompt which changes with
executable name and context. For example, 
"pirl @>", "pirl $>", and "pirl >".

=back

=head1 GORY DETAILS

=head2 ABOUT EVALUATION

When the statement read is evaluated, this is done 
at a different package, which is C<Shell::Perl::sandbox> 
by default.

So:

    $ perl -Mlib=lib bin/pirl
    Welcome to the Perl shell. Type ':help' for more information

    pirl @> $a = 2;
    2

    pirl @> :set out Y # output in YAML

    pirl @> \%Shell::Perl::sandbox::
    ---
    BEGIN: !!perl/glob:
      PACKAGE: Shell::Perl::sandbox
      NAME: BEGIN
    a: !!perl/glob:
      PACKAGE: Shell::Perl::sandbox
      NAME: a
      SCALAR: 2

This package serves as an environment for the current
shell session and :reset can wipe it away.

    pirl @> :reset

    pirl @> \%Shell::Perl::sandbox::
    ---
    BEGIN: !!perl/glob:
      PACKAGE: Shell::Perl::sandbox
      NAME: BEGIN


=head1 TO DO

There is a lot to do, as always. Some of the top priority tasks are:

=over 4

=item *

Accept multiline statements;.

=item *

Refactor the code to promote easy customization of features.

=back

=head1 SEE ALSO

This project is hosted at Google Code:

    http://code.google.com/p/iperl/

To know about interactive Perl interpreters, there are two
FAQS contained in L<perlfaq3> which are good starting points.
Those are

    How can I use Perl interactively?
    http://perldoc.perl.org/perlfaq3.html#How-can-I-use-Perl-interactively%3f

    Is there a Perl shell?
    http://perldoc.perl.org/perlfaq3.html#How-can-I-use-Perl-interactively%3f

An extra list of Perl shells can be found here:

    http://www.focusresearch.com/gregor/document/psh-1.1.html#other_perl_shells

=head1 BUGS

There are some quirks with Term::Readline (at least on Windows).

There are more bugs. I am lazy to collect them all and list them now.

Please report bugs via CPAN RT L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Shell-Perl>.

=head1 AUTHOR

Adriano R. Ferreira, E<lt>ferreira@cpan.orgE<gt>

Caio Marcelo, E<lt>cmarcelo@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Adriano R. Ferreira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
