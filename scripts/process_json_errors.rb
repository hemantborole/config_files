#!/usr/bin/env ruby

require 'strscan'
require 'json'

H = %w(YPCO YELP YHOO GOOG FACE MAPQ SPPG DEXK LOC IND FACT CITY LOCL FRSQ MERCH BING ACX)

hdr = "ypid,ds,#{H.join(',')}"
puts hdr

fd = IO.sysopen(ARGV[0],'r')
stream = IO.new(fd)
stream.each_line {|l|
  l.chomp!
  begin
    j = JSON.parse(l)
    next unless j['summary']
    next unless j['summary']['mismatches']
    m = j['summary']['mismatches']
    ms = j['summary']['missing']
    mis = {}
    H.each { |src| 
      if j['summary']['unknown_sites'] && j['summary']['unknown_sites'].include?(src)
        mis[src] = 7
      else
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
      end
    }
    H.each { |src| 
      next if mis[src] >= 7
      ms.each{|s|
        if ( s["source_code"].eql?(src) )
          mis[src] = mis[src] +  s['missing'].length
          break
        end
      }
    }
    puts "#{j['id']},20150222,#{mis.values.join(',')}"
  rescue JSON::ParserError => j
    ## Swallow
  end
}

