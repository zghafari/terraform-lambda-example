resource "aws_iam_role" "lambda_role" {
  name = "LambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Modify this policy to give more permissions to Lambda
resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "LambdaRolePolicy"
  role = "${aws_iam_role.lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",     
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambda/example.js"
  output_path = "${path.module}/lambda/example.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/lambda/example.zip"
  function_name    = "hello_world_example"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "example.handler"
  source_code_hash = "${data.archive_file.lambda_archive.output_base64sha256}"
  runtime          = "nodejs8.10"
}