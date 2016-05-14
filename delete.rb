def deleteStack(stackName, user, key, verbose)
  puts("Deleting stack")

  puts("Checking if stack " + stackName + " exists")

  stackExists = `aws cloudformation describe-stacks --stack-name #{stackName} 2>&1`.strip

  if verbose
    puts("stackExists = " + stackExists)
  end


  if stackExists.include?("does not exist")
    puts("Stack " + stackName + " does not exist.  Exiting.")
    exit(100)
  end


  deleteStack = `aws cloudformation delete-stack --stack-name #{stackName}`

  if verbose
    puts("deleteStack = " + deleteStack)
  end

  puts("Deletion of stack " + stackName + " underway")

  deleteFinished = false

  while !deleteFinished
    sleep(10)

    puts("Checking status of stack " + stackName)

    stackExists = `aws cloudformation describe-stacks --stack-name #{stackName} 2>&1`.strip

    if verbose
      puts("stackExists = " + stackExists)
    end

    if stackExists.include?("does not exist")
      puts("Deletion of stack " + stackName + " complete.  Exiting.")
      exit(0)
    end

    stackStatus = JSON.parse(stackExists)["Stacks"][0]["StackStatus"]

    puts("Stack " + stackName + " status is " + stackStatus)


  end


end