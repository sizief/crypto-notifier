package BTC::Client;

use feature 'say';
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_SUB ZMQ_SUBSCRIBE ZMQ_POLLIN);
use utf8;
use Bitcoin::RPC::Client;
use JSON::MaybeXS;
use Data::Dumper;

sub hexlify {
    my $input = shift;
    my @arr;
    for my $c (split //, $input) {
        push @arr,  sprintf("%02X", ord($c));
    }
    return join("",@arr)
}

sub get_addresses {
    my $rawtx = shift;
    $btc = Bitcoin::RPC::Client->new(
        user     => "sizief",
        password => "myheart",
        host     => "127.0.0.1"
    );

    my @addresses;
    my $json_body = $btc->decoderawtransaction($rawtx);
    for my $trx (@{$json_body->{vout}}) { 
        push @addresses, $trx->{scriptPubKey}->{addresses}[0];
    }
    return \@addresses;
}

sub daemon {
    my $context = zmq_init();
    my $subscriber = zmq_socket($context, ZMQ_SUB);
    zmq_connect($subscriber, 'tcp://localhost:28332');
    #zmq_setsockopt($subscriber, ZMQ_SUBSCRIBE, "hashtx");
    zmq_setsockopt($subscriber, ZMQ_SUBSCRIBE, "rawtx");

    while (1) {
        my $topic = zmq_msg_data(zmq_recvmsg($subscriber));
        my $body = zmq_msg_data(zmq_recvmsg($subscriber));
        my $sequence = zmq_msg_data(zmq_recvmsg($subscriber));
        my @sequence_arr = unpack("v",$sequence);
        say Dumper get_addresses hexlify($body);
        #return get_addresses hexlify($body);
    }
}


1;