resource "aws_ecs_service" "this" {
  count = var.create_adot_service ? 1 : 0
  
  name = "${var.name}-otel-collector"
  cluster = var.cluster
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = 3
  iam_role = aws_iam_role.this.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.this[0].arn
    container_name = "otel-collector"
    container_port = 4318
  }
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_adot_service ? 1 : 0

  name = "/ecs/${var.name}-otel-collector"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  count = var.create_adot_service ? 1 : 0

  family = "${var.name}-otel-collector"
  network_mode = "awsvpc"
  cpu = var.otel_collector_cpu
  memory = var.otel_collector_memory
  
  container_definitions = jsonencode([
    {
      name = "otel-collector"
      image = var.otel_collector_image
      cpu = var.otel_collector_cpu
      memory = var.otel_collector_memory
      essential = true
      command = [var.adot_collector_command]
      portMappings = [
        {
          containerPort = 4318
          hostPort = 4318
        }
      ]
      environment = [
        {
          name = "AWS_PROMETHEUS_ENDPOINT"
          value = aws_prometheus_workspace.this[0].prometheus_endpoint
        }
      ]
      logging_configuration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = aws_cloudwatch_log_group.this.name
          "awslogs-region" = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_iam_role" "this" {
  count = var.create_adot_service ? 1 : 0

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
  count  = var.create_adot_service ? 1 : 0
  
  role   = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "prometheus" {
  count  = var.create_adot_service ? 1 : 0
  
  role   = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}