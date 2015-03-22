#!/usr/bin/ruby
input = File.new( '/tmp/out1.out')

while( line = input.gets )
  #u = match( $0, /[[:alnum:]]{8}(-[[:alnum:]]{4}){3}-[[:alnum:]]{12}/ )
  h = line.match(/"hostname": "(.*[^"])*",/)
  puts h[1]
end
