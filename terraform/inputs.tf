variable "bootstrap_image_name" {
  default     = "111122223333.dkr.ecr.us-east-1.amazonaws.com/test-lambda"
  type        = string
  description = "Container image name for the initial bootstrap image. This value will be ignored after initial apply."
}

variable "bootstrap_image_tag" {
  default     = "latest"
  type        = string
  description = "The container image tag for the initial bootstrap image. This value will be ignored after initial apply."
}

variable "environment_variables" {
  type = map(string)
  default = {
    foo = "bar"
  }
  description = "Map of environment variables provided to the Lambda function."
}

variable "function_name" {
  default     = "test-lambda"
  type        = string
  description = "Lambda function name"
}

variable "memory_size" {
  default     = 128
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128. Ref: https://docs.aws.amazon.com/lambda/latest/dg/limits.html"
}
