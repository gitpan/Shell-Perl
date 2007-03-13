
use ExtUtils::MakeMaker 6.31;

WriteMakefile(
  NAME => 'Shell::Perl',
  VERSION_FROM => 'lib/Shell/Perl.pm',
  PREREQ_PM => {
    Term::ReadLine  => 0,
    Data::Dumper    => 0,
    YAML            => 0,
    Data::Dump      => 0,


    Class::Accessor => 0,
  },
  EXE_FILES => [ 'bin/pirl' ],
  LICENSE => 'perl', # needs ExtUtils::MakeMaker >= 6.31

);

