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

resource "aws_lambda_function" "test_lambda" {
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn

  # Initial bootstrap container image intended to be overwritten by deploy pipelines in external CI/CD systems.
  # NOTE: The bootstrap image must already exist in ECR before first apply.
  image_uri    = "${var.bootstrap_image_name}:${var.bootstrap_image_tag}"
  package_type = "Image"

  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  # Ignore changes to the image URI made by external CI/CD
  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }
}
