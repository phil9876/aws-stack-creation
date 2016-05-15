#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'optparse'

String stackName = ENV["STACK_NAME"]
String key = ENV["AWS_KEY"]
verbose = false

user = ENV["USER"]

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: provision.rb --command=command [options]"

  opts.on("--key=key", "The key to use") do |k|
    key = k
  end

  opts.on("--stackName=stack", "The name of the stack to create") do |s|
    stackName = s
  end

  opts.on("-v", "--verbose", "Run in verbose mode") do |v|
    verbose = true
  end
end.parse!

if verbose
  puts("key = " + key)
  puts("stackName = " + stackName)
end

puts("Checking if stack " + stackName + " exists")

stackExists = `aws cloudformation describe-stacks --stack-name #{stackName} 2>&1`.strip

if verbose
  puts("stackExists = " + stackExists)
end


if stackExists.include?("does not exist")
  puts("Stack " + stackName + " does not exist.  Exiting.")
  exit(100)
end

stackResources = `aws cloudformation describe-stack-resources --stack-name #{stackName}`

if verbose
  puts("stackResources = " + stackResources)
end

ec2InstanceId = JSON.parse(stackResources)["StackResources"][0]["PhysicalResourceId"]

stackInstance  = `aws ec2 describe-instances --instance-id #{ec2InstanceId}`

if verbose
  puts("stackInstance = " + stackInstance)
end

ec2IpAddress = JSON.parse(stackInstance)["Reservations"][0]["Instances"][0]["PublicIpAddress"]

puts("The private IP address of your EC2 instance is " + ec2IpAddress + ", the instance Id is " + ec2InstanceId)


puts("Provisioning Tomcat on EC2 instance")

system("ansible-playbook site.yml -i \"#{ec2IpAddress},\" -u ec2-user --key-file=/Users/#{user}/.ssh/#{key}.pem")