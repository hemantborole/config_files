#!/usr/bin/env ruby

ROLE = [REQUIRED, OPTIONAL, ORGANIZER]
class User
  attr_accessor :first, :last, :email, :role, :action
end

class Event
  attr_accessor :subject, :body, :when, :where, :recurring, :content, :participants, :attachments

  def initialize(cal_file)
    File.read( cal_file )
  end

  def participants=( p )
    @participants ||= p
  end
end
