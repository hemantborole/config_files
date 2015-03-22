#!/usr/bin/env jruby

f1 = STDOUT

bigo = {}

main = Thread.new( "main" )  {

  t1 = Thread.new( 't1' ) {
    bigo[:time] = rand(5)
    f1.puts "Executing thread 1 for #{bigo[:time]}"
    sleep bigo[:time]
    f1.puts "Exiting thread 1"
  }
  t2 = Thread.new( 't2' ) {
    bigo[:time] = rand(5)
    f1.puts "Executing thread 2 for #{bigo[:time]}"
    sleep bigo[:time]
    f1.puts "Exiting thread 2"
  }

  t3 = Thread.new( 't3' ) {
    while( true ) do
      if not t1.alive?
        if bigo[:time] >= 3
          f1.puts "t1 is dead and has time >=3, Killing thread t2"
          t2.kill if t2.alive?
        else
          f1.puts "t1 is dead but has time <3, Waiting for thread t2"
          t2.join
        end
      elsif not t2.alive?
        f1.puts "t2 is dead, Waiting for thread t1"
        t1.join
      end

      break if not( t1.alive? and t2.alive? )
    end
    }
  t3.join
  f1.puts "Exiting thread 3"
}

main.join
final = bigo[:time]
f1.puts "Exiting main thread #{final}"
