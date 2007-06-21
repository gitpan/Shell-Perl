
use 5;
use ExtUtils::MakeMaker;

my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
  NAME => 'Shell::Perl',
  VERSION_FROM => 'lib/Shell/Perl.pm',
  PREREQ_PM => {
    Term::ReadLine  => 0,
    File::Basename  => 0,
    Class::Accessor => 0,

    Test::More      => 0,

#    optionals
#    Data::Dumper    => 0,
#    YAML            => 0,
#    Data::Dump      => 0,

  },
  EXE_FILES => [ 'bin/pirl' ],

  ($] >= 5.005 ? (
    ABSTRACT_FROM  => 'lib/Shell/Perl.pm', 
    AUTHOR         => 'A. R. Ferreira <ferreira@cpan.org>',
  ) : ()),
  ($EUMM_VERSION >= 6.31 ? (
    LICENSE => 'perl', 
  ) : ()),

);

# recommended:
#   - one_of: [ YAML::Syck, YAML ]
#   - Data::Dump
#   - Data::Dumper
#   - Test::Pod 
#   - Test::Pod::Coverage
