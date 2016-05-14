#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'optparse'

String key = ''
String ec2IpAddress = ''
verbose = false

user = ENV["USER"]

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: provision.rb --command=command [options]"

  opts.on("--key=KEY", "The key to use") do |k|
    key = k
  end

  opts.on("--ip=IPADDRESS", "The IP address of the instance to install Tomcat on") do |i|
    ec2IpAddress = i
  end

  opts.on("-v", "--verbose", "Run in verbose mode") do |v|
    verbose = true
  end
end.parse!

if verbose
  puts("key = " + key)
  puts("ec2IpAddress = " + ec2IpAddress)
end


puts("Provisioning Tomcat on EC2 instance")

system("ansible-playbook site.yml -i \"#{ec2IpAddress},\" -u ec2-user --key-file=/Users/#{user}/.ssh/#{key}.pem")