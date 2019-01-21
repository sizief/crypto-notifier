use Test::More;
use Cwd;
use Data::Dumper;
use BTC::Client;
use feature 'say';

#my $filename = getcwd.'/t/sample_json';
my $filename = getcwd.'/t/sample_raw_transaction';
my $raw_transaction = '';
open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
while (my $row = <$fh>) {$raw_transaction .= $row;}

#my $res = BTC::Client::get_addresses($raw_transaction);
my $res = BTC::Client::get_addresses($raw_transaction);
my @expected = ('38Zc9FN9Li39bBztYSoXATdCoW1BNYwM4j', '16vdaSXqwmVDkN7x1ZEUsuA2wzTSFYYzLm');

#say 'res: '.Dumper $res;
#say 'exp: '.Dumper @expected;

ok(@$res eq @expected);

done_testing();