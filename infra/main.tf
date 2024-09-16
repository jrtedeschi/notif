provider "aws" {
    region = "us-west-2"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_role" "lambda_role" {
  name = "alertas_cemaden_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "alertas_cemaden_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = "sns:Publish",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "alertas_cemaden"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  filename      = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

resource "aws_sns_topic" "alertas_cemaden" {
  name = "alertas_cemaden"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alertas_cemaden.arn
  protocol  = "email"
  endpoint  = "joaorafaelbt@gmail.com"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.alertas_cemaden.arn
  protocol  = "sms"
  endpoint  = "+5511995531032"
  
}

resource "aws_sfn_state_machine" "exec_alertas_cemaden" {
  name     = "alertas_cemaden"
  role_arn = aws_iam_role.lambda_role.arn
  definition = jsonencode({
    Comment: "A simple AWS Step Functions state machine that invokes a Lambda function and sends an SNS notification.",
    StartAt: "InvokeLambda",
    States: {
      InvokeLambda: {
        Type: "Task",
        Resource: aws_lambda_function.my_lambda.arn,
        ResultPath: "$.lambdaResult",
        Next: "SendNotification"
      },
      SendNotification: {
        Type: "Task",
        Resource: "arn:aws:states:::sns:publish",
        Parameters: {
          Message: {
            "Fn::Sub": "Lambda function executed successfully with result: ${lambdaResult}"
          },
          TopicArn: aws_sns_topic.my_topic.arn
        },
        End: true
      }
    }
  })
}