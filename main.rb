#!/usr/bin/ruby -w

require_relative "lib/client/models"
include Periskop::Client


def div()
    return 1/0 
end

begin  
    div()
rescue Exception => e
    exception = ExceptionInstance.new(e.class.name, e.message, e.backtrace.inspect, e.cause)
    puts exception.class
    puts exception.message
    puts exception.stacktrace
end  
