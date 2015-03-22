#!/usr/bin/env spec
require 'rubygems'

class ConfigParser
  def strip_comment(line)
    return '' if line.class != String 
    str = ( m =  line.strip.match( /([^#]*)#.*/ ) ) ? m[1].strip : line.strip
  end
end

describe ConfigParser do
  cfgParser = ConfigParser.new
  it "returns '' for nil" do
    str = cfgParser.strip_comment(nil)
    str.should == ''
  end
  it "returns 'empty string' " do
    str = cfgParser.strip_comment( "## This is a coment" )
    str.should == ''
  end
  it "returns 'empty string' " do
    str = cfgParser.strip_comment( " ## This is a coment" ) ## Space before hash
    str.should == ''
  end
  it "returns 'Text without comments' " do
    str = cfgParser.strip_comment( "  Text without comments " ) ## Space before hash
    str.should == 'Text without comments'
  end
  it "returns 'Some text with comments' " do
    str = cfgParser.strip_comment( "Some text with comments ## This is a coment" )
    str.should == 'Some text with comments'
  end
  it "returns 'String with hash' " do
    str = cfgParser.strip_comment( 'Some text with comments \# This is not a coment' )
    str.should_not == 'Some text with comments \# This is not a comment'
  end
end
