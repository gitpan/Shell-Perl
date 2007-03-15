
use 5;
use ExtUtils::MakeMaker;

my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
  NAME => 'Shell::Perl',
  VERSION_FROM => 'lib/Shell/Perl.pm',
  PREREQ_PM => {
    Term::ReadLine  => 0,
#    Data::Dumper    => 0,
#    YAML            => 0,
#    Data::Dump      => 0,

    Class::Accessor => 0,
  },
  EXE_FILES => [ 'bin/pirl' ],

  ($EUMM_VERSION >= 6.31 ? (
    LICENSE => 'perl', 
  ) : ()),

);

