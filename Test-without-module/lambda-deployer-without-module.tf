provider "aws" {
  profile    = "default"
  region     = "eu-central-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

variable "lambda_layers" {
  type = "list"
  description = "list of custom layers"
  default = ["arn:aws:lambda:eu-central-1:209497400698:layer:php-74:1"] 
}

resource "aws_lambda_function" "lambda-php" {
  filename      = "../lambda-function.zip"
  function_name = "ReleaseNameGenerator"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "lambda-function/index.php"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:

  source_code_hash = "${filebase64sha256("../lambda-function.zip")}"

  runtime = "provided"
  layers = var.lambda_layers

}