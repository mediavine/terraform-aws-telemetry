data "aws_caller_identity" "current" {}

################################################################################
# Policies
################################################################################

resource "aws_iam_policy" "cw_logs_policy" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name        = "${var.name}-otel-collector-cw-logs-policy"
  path        = "/"
  description = "Policy to create and access adot logs"

  policy = templatefile("${path.module}/policies/cw_logs_access.json", {
    name = "${var.name}",
  })
}

resource "aws_iam_policy" "ssm_parameter_access" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name        = "SSMParameterAccessPolicy"
  description = "Policy to allow access to custom OTEL config SSM parameter"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ]
        Resource = aws_ssm_parameter.custom_otel_config[0].arn
      }
    ]
  })
}

resource "aws_iam_policy" "task_execution" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name        = "${var.name}-otel-collector-task-execution-policy"
  path        = "/"
  description = "Policy to allow the ECS task to execute"

  policy = templatefile("${path.module}/policies/ecs_full_access.json", {
    aws_account_id = data.aws_caller_identity.current.account_id,
    cluster        = var.cluster,
    service_name   = aws_ecs_service.this[0].name,
  })
}
################################################################################
# Task Role
################################################################################

resource "aws_iam_role" "task_role" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name = "${var.name}-otel-collector-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "xray" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  role       = aws_iam_role.task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "prometheus" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  role       = aws_iam_role.task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}

resource "aws_iam_role_policy_attachment" "cw_logs_policy_attachment" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  role       = aws_iam_role.task_role[0].name
  policy_arn = aws_iam_policy.cw_logs_policy[0].arn
}

################################################################################
# Execution Role
################################################################################
resource "aws_iam_role" "execution_role" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name = "${var.name}-collector-exc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  role       = aws_iam_role.execution_role[0].name
  policy_arn = aws_iam_policy.task_execution[0].arn
}

resource "aws_iam_role_policy_attachment" "cw_logs_policy_attachment_execution_role" {
  count = var.create_adot_service ? 1 : 0

  role       = aws_iam_role.execution_role[0].name
  policy_arn = aws_iam_policy.cw_logs_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm_parameterstore_policy_attachment" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  role       = aws_iam_role.execution_role[0].name
  policy_arn = aws_iam_policy.ssm_parameter_access[0].arn
}