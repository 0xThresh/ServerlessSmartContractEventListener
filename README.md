# Smart Contract Event Listener
This repo acts as a combined codebase with an example of using AWS serverless resources to automate listening to 
smart contract events with a service in ECS, sending the data from the event to a message in SQS, and using the 
data to trigger an AWS Lambda function to send another transaction. This was built for a project during the FVM
Space Warp hackathon in 2023, but could be used as a starting point for many other use cases. 

## Infrastructure
A few components are built to support this backend. An ECS service on Fargate acts as an event listener, which listens for a specific smart contract event. When the event is emitted, its return values are gathered by the listener, and sent to a message in SQS. The SQS message then triggers an AWS Lambda function, which then performs an action (in my case, reaching out to filrep.io to determine a miner ID's reputation) and then uses the output of that action as inputs for another smart contract transaction. The diagram below visualizes the process. 
<Insert Diagram Here>

## Prerequisites
A basic understanding of AWS and Terraform is helpful in using this codebase. If you have not worked with either before, the most important thing for you to know is that **AWS resources cost money, and that you need to destroy any resources you build that you don't plan to keep using so you don't get charged. THE RESOURCES BUILT BY RUNNING THIS CODE WILL COST YOU MONEY, AND I AM NOT RESPONSIBLE FOR ANY CHARGES YOU INCUR BY NOT DELETING THESE RESOURCES.** I've included a section below to destroy the resources once you've tested them so you can avoid giving your money to AWS unintentionally. If you only run the resources for a very short period of time, you should not incur any significant charges. 

In order to deploy these resources, you must have an AWS account. If you do not have an AWS account, you can sign up for one here: https://portal.aws.amazon.com/billing/signup/iam?#/account

You must have `aws-cli` installed on your local machine: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html 

You must have an AWS access key and secret key set up, and add them to your local profile by running `aws configure`: https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/ 

You must have Terraform installed. I personally recommend downloading it with `tfenv` to make Terraform version management easier: https://github.com/tfutils/tfenv 

## Running the Code
Once all the above prerequisites are met, the following Terraform commands can be run to begin building the resources. 

### Example Run Commands 
`cd ./terraform/prod`
`terraform init`
`terraform apply`

### Deployment Sequence 
When building the resources, the following steps are performed (which can be viewed in detail in the `terraform/prod/main.tf` file): 
1. Docker image is built using the Dockerfile in this repo
2. The ECR repo is built 
3. The docker image built in step 1 is pushed to the ECR repo built in step 2
4. Terraform builds all remaining serverless components and dependencies 

## Destroying Resources 
In order to destroy all resources with Terraform, run the following commands: 
`cd ./terraform/prod`
`terraform destroy`

## Troubleshooting
1. Error: invalid contract address or ENS name (argument="addressOrName", value=undefined, code=INVALID_ARGUMENT, version=contracts/5.7.0)
- The environment variable representing the contract is probably named incorrectly. Ensure that it matches the variable used in the Lambda function's code. 
2. TypeError: Cannot read properties of undefined (reading 'toHexString')
- The private key environment variable hasn't been added to the Lambda function. 