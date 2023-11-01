data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "bootstrap_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_bootstrap.zip"

  source {
    content  = "hello"
    filename = "bootstrap.txt"
  }
}

resource "aws_lambda_function" "test_lambda" {
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn

  filename         = data.archive_file.bootstrap_lambda.output_path
  package_type     = var.package_type
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = data.archive_file.bootstrap_lambda.output_base64sha256

  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  # Ignore changes to the image URI made by external CI/CD
  lifecycle {
    ignore_changes = [source_code_hash]
  }
}
