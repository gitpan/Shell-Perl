
use Test::More;

eval "use Test::Expect";
plan skip_all => "Test::Expect required for testing" if $@;

# test pirl and its many quit commands

plan( tests => 2*6 );

for my $quit_command ( ':quit', ':q', ':exit', ':x', 'exit', 'quit' ) {

    expect_run(
        command => "$^X -Mblib blib/script/pirl --noornaments",
        prompt  => 'pirl @> ',
        quit    => $quit_command,
    );

    expect_like(qr/^Welcome/, "welcome message");

}
