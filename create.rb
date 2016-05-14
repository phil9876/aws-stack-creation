def createStack(stackName, user, key, verbose)

  puts("Creating stack")

  puts("Checking that stack " + stackName + " doesn't already exist")

  stackExists = `aws cloudformation describe-stacks --stack-name #{stackName} 2>&1`.strip

  if verbose
    puts("stackExists = " + stackExists)
  end


  unless stackExists.include?("does not exist")
    puts("Stack " + stackName + " already exists.  Exiting.")
    exit(100)
  end


  puts("Creating stack " + stackName)

  if verbose
    puts("Executing 'aws cloudformation create-stack --stack-name #{stackName} --template-body file://#{Dir.pwd}/ec2.template'")
  end

  stackCreation = `aws cloudformation create-stack --stack-name #{stackName} --template-body "file://#{Dir.pwd}/ec2.template"`

  if verbose
    puts(stackCreation)
  end


  if $?.exitstatus != 0
    puts("Error creating stack " + stackName + ".  aws returned status of " + $?.exitstatus.to_s + ".  Exiting.")
    exit 100
  end

  createFinished = false

  while !createFinished
    sleep(10)

    puts("Checking status of stack " + stackName)

    stackStatusString = `aws cloudformation describe-stacks --stack-name #{stackName}`

    if verbose
      puts("stackStatusString = " + stackStatusString)
    end

    stackStatus = JSON.parse(stackStatusString)["Stacks"][0]["StackStatus"]

    puts("Stack " + stackName + " status is " + stackStatus)

    if stackStatus == "CREATE_FAILED" || stackStatus == "ROLLBACK_COMPLETE"
      puts("Stack creation failed.  Status is " + stackStatus + ".  Exiting")
      exit 200
    end

    if stackStatus == "CREATE_COMPLETE"
      createFinished = true
    end

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


  puts("Waiting for EC2 instance to finish booting.......")

  instanceUp=false

  while !instanceUp
    sleep(10)

    puts("Checking reachability status of EC2 instance.....")

    ec2Status = `aws ec2 describe-instance-status --instance-id #{ec2InstanceId}`

    if verbose
      puts("ec2Status = " + ec2Status)
    end


    ec2ReachabilityStatus = JSON.parse(ec2Status)["InstanceStatuses"][0]["InstanceStatus"]["Details"][0]["Status"]

    if ec2ReachabilityStatus != "initializing"
      instanceUp = true

      puts(" EC2 reachaibility status is " + ec2ReachabilityStatus)
    end

    puts("EC2 reachaibility status is " + ec2ReachabilityStatus)

  end

  puts("Adding public key for " + ec2IpAddress + " to known hosts")

  ignore = `ssh-keyscan -H #{ec2IpAddress} >> ~/.ssh/known_hosts`


  puts("Provisioning Tomcat on EC2 instance")

#system("ansible-playbook site.yml -i \"#{ec2IpAddress},\" -u ec2-user --key-file=/Users/#{user}/.ssh/#{user}-nonprod.pem")


  puts("Your environment is now provisioned.  You can connect to it by using 'ssh -i /Users/#{user}/.ssh/#{key} ec2-user@#{ec2IpAddress}'")

end
