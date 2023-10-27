# iac-lambda-with-external-ci

Proof-of-concept setting up an AWS Lambda function via Terraform that runs a container image from AWS ECR,
where the configured image is managed by an external CI/CD pipeline.
This allows the infrastructure to be managed separately from the Lambda code.

The Lambda function container image and code is from the AWS docs
[Using an alternative base image with the runtime interface client](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-image.html#nodejs-image-clients).

## Prerequisites

- AWS account

- AWS ECR repository

    Using `111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda` as the example here

- Docker

- Terraform

## Walkthrough

- Build container image

    ```text
    $ docker build -t 111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda:latest \
          -f function/Dockerfile function/
    ```

- Push image to ECR

    ```text
    $ aws ecr get-login-password --region us-east-1 \
          | docker login --username AWS --password-stdin 111122223333.dkr.ecr.us-east-1.amazonaws.com

    $ docker push 111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda:latest
    ```

- Provision AWS Lambda via Terraform

    ```text
    $ terraform -chdir=terraform init

    $ terraform -chdir=terraform apply
    ```

- Make some function code changes and build a new image

    ```text
    $ docker build -t 111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda:v2 \
          -f function/Dockerfile function/

    $ docker push 111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda:v2
    ```

- Update the image URI for the Lambda function via `aws` cli

    ```text
    $ aws lambda update-function-code \
          --function-name test-lambda \
          --image-uri 111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda:v2
    ```

- Confirm that Terraform does not show any drift even though image URI changed

    ```text
    $ terraform -chdir=terraform plan
    data.aws_iam_policy_document.assume_role: Reading...
    data.aws_iam_policy_document.assume_role: Read complete after 0s [id=2690255455]
    aws_iam_role.iam_for_lambda: Refreshing state... [id=iam_for_lambda]
    aws_lambda_function.test_lambda: Refreshing state... [id=test-lambda]

    No changes. Your infrastructure matches the configuration.

    Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
    ```

Now developers can iterate on Lambda function code with an external CI system without having to change Terraform configuration.
