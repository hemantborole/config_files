#/usr/bin/env ruby
#

file_in = File.readlines(ARGV[0])
fd = File.open("error_report.csv","r")
fo = File.open("premium_errors_out.csv","w+")

file_in.each { |line|
  line.chomp!
  fd.rewind
  greps = fd.grep(/^#{line},/)
  greps.each { |g| fo.write(g) }
}

fo.close
fd.close
