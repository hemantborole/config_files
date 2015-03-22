require 'json'
my_json = File.read(ARGV[0])
puts JSON.pretty_generate(my_json)
