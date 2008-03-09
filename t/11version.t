
use Test::More no_plan => 1;

my @pirl = ( $^X, '-Mblib', 'blib/script/pirl' );

use IPC::Cmd qw( run );
use Test::Deep;

for my $switch ( '-v', '--version' ) {
    my ( $ok, $err, $full_buf, $out_buf, $err_buf )  = run( command => [ @pirl, $switch ] );
    ok( $ok, "'pirl $switch' run ok" );
    is( $err, 0, 'exited with 0' );
    cmp_deeply( $out_buf, [ re(qr/\AThis is pirl/) ], 'printed version info' );
    cmp_deeply( $err_buf, [], 'no output to STDERR' );
}
