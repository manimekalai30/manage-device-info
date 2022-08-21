terraform {
  required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_role" "role" {
    name = "device_info_lambda_roles"
    assume_role_policy = jsonencode(
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
})
}

resource "aws_iam_policy" "policy" {
    name = "aws_iam_role_policy_for_device_info_lambda_role"

  # Terraform's "jsonencode" function converts a 
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"logs:DescribeLogStreams"
			],
			"Resource": [
				"arn:aws:logs:*:*:*"
			]
		},
    {
   "Effect": "Allow",
    "Action": [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ],
    "Resource": "*"
    }
	]
})
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
    role = aws_iam_role.role.name
    policy_arn = aws_iam_policy.policy.arn
}


data archive_file zip_device_info_lambda_code {
  type        = "zip"
  source_dir = "${path.module}/src"
  output_path = "${path.module}/device_info.zip"
}

resource "aws_lambda_function" "device_info_lambda_function" {
    filename = "${path.module}/device_info.zip"
    function_name = "bosch-interview-device-information"
    role = aws_iam_role.role.arn
    handler = "device_info/index.handler"
    runtime = "nodejs16.x"
}   

resource "aws_apigatewayv2_api" "device_info_lambda_integration" {
  name          = "learning-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "device_info_lambda_integration" {
  api_id = aws_apigatewayv2_api.device_info_lambda_integration.id
  integration_uri    = aws_lambda_function.device_info_lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.device_info_lambda_integration.id
  name        = "dev"
  auto_deploy = true
}


resource "aws_apigatewayv2_route" "device_info_lambda_integration" {
  api_id = aws_apigatewayv2_api.device_info_lambda_integration.id
  route_key = "POST /insert-device-info"
  target    = "integrations/${aws_apigatewayv2_integration.device_info_lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.device_info_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.device_info_lambda_integration.execution_arn}/*/*"
}