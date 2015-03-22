#!/usr/bin/env ruby

require 'strscan'
require 'json'

H = %w(YELP YHOO GOOG FACE YPCO BING MAPQ FRSQ LOCL SPPG CITY MERCH )

hdr = "ypid,ds,#{H.join(',')}"
puts hdr

fd = IO.sysopen(ARGV[0],'r')
stream = IO.new(fd)
stream.each_line {|l|
  l.chomp!
  ss = StringScanner.new(l)
  line = ss.scan(/\s+(\d+)\s+column=ds:(\d+),\s+timestamp=\d+,\s+value=(.*)/)    # Grab a word at a time
  if line
    ypid = ss[1]
    ds = ss[2]
    value = ss[3] 
    begin
      j = JSON.parse(value)
      next unless j['summary']
      next unless j['summary']['mismatches']
      m = j['summary']['mismatches']
      #puts m
      mis = {}
      H.each { |src| 
        found=0
        m.each{|s|
          if ( s["source_code"].eql?(src) )
            mis[src] = s['mismatches'].length
            found=1
            break
          end
        }
        if found == 0
          mis[src]=0
        end
      }
      puts "#{ypid},#{ds},#{mis.values.join(',')}"
    rescue JSON::ParserError => j
      ## Swallow
    end
  end
}

