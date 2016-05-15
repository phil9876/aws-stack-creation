#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'optparse'

require_relative 'create'
require_relative 'delete'

String command = ''
String stackName = 'myStack'
String key = "PhilsAWSKey"
verbose = false

user = ENV["USER"]

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: provision.rb --command=command [options]"

  opts.on("--command=COMMAND", "The command to run") do |c|
    command = c
  end

  opts.on("--key=KEY", "The key to use") do |k|
    key = k
  end

  opts.on("--stackName=STACK", "The name of the stack to create") do |s|
    stackName = s
  end

  opts.on("--verbose", "Run in verbose mode") do |v|
    verbose = true
  end
end.parse!


case command
  when "create"
    createStack(stackName, user, key, verbose)
  when "delete"
    deleteStack(stackName, user, key, verbose)
  else
    puts("Command " + command + " is invalid.  Exitting")
    exit(300)
end







