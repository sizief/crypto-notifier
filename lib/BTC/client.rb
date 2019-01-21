# regtest=1
# ~/Library/Application\ Support/Bitcoin/bitcoin.conf

require 'rubygems'
require 'ffi-rzmq'
require "base64"
require 'strscan'

message = Array.new
topic = ''
body = ''
remaining = ''

module Binascii
    def self.hexlify(s)
      a = []
      s.each_byte do |b|
        a << sprintf('%02X', b)
      end
      a.join
    end
   
    def self.unhexlify(s)
      a = s.split
      return a.pack('H*')
    end
  end
  #puts Binascii.hexlify('123')


def error_check(rc)
    if ZMQ::Util.resultcode_ok?(rc)
      false
    else
      STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
      caller(1).each { |callstack| STDERR.puts(callstack) }
      true
    end
end

context = ZMQ::Context.new(1)

puts "Collecting updates from node"
subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:28332")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "hashblock")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "hashtx")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "rawblock")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "rawtx")

loop do
  rc = subscriber.recv_string(topic)
  subscriber.recv_string(body) if subscriber.more_parts?
  subscriber.recv_string(remaining) 
  sequence = remaining.nil? ? "unknown" : remaining.unpack('<I')[0].to_s 

  puts topic+"->"+sequence
  puts `bitcoin-cli decoderawtransaction #{Binascii.hexlify(body)}` if topic == 'rawtx'  
end

