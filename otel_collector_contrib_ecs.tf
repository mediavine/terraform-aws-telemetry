locals {
  default_config_environment = [
    {
      name  = "AWS_REGION"
      value = var.region
    }
  ]

  custom_config_environment = [

    {
      name      = "CUSTOM_OTEL_CONFIG"
      valueFrom = "${aws_ssm_parameter.custom_otel_config[0].arn}"
    }
  ]

  environment = var.custom_otel_config[0].otel_config_file_path != null ? local.custom_config_environment : local.default_config_environment
}

resource "random_string" "this" {
  length  = 7
  special = false
  upper   = true
  lower   = false
}

resource "aws_ssm_parameter" "custom_otel_config" {
  count = var.custom_otel_config != null ? 1 : 0

  name  = "CUSTOM_OTEL_CONFIG_${random_string.this.result}"
  type  = "String"
  value = file(var.custom_otel_config[0].otel_config_file_path)
}

resource "aws_ecs_service" "otel_collector_ecs_service" {
  count = var.create_otel_collector_service ? 1 : 0

  name            = "${var.name}-otel-collector"
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.otel_collector_task_definition[0].arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count
  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.this[0].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.http[0].arn
    container_name   = "otel-collector"
    container_port   = 4318
  }
}

resource "aws_cloudwatch_log_group" "otel_collector_log_group" {
  count = var.create_otel_collector_service ? 1 : 0

  name              = "/ecs/${var.name}-otel-collector"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "otel_collector_task_definition" {
  count = var.create_otel_collector_service ? 1 : 0

  family                   = "${var.name}-otel-collector-contrib"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.otel_collector_cpu
  memory                   = var.otel_collector_memory
  execution_role_arn       = aws_iam_role.execution_role[0].arn
  task_role_arn            = aws_iam_role.task_role[0].arn

  container_definitions = jsonencode([
    {
      name      = "otel-collector"
      image     = var.otel_collector_image
      cpu       = var.otel_collector_cpu
      memory    = var.otel_collector_memory
      essential = true
      command   = var.custom_otel_config != null ? ["--config=env:${aws_ssm_parameter.custom_otel_config[0].arn}"] : []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.otel_collector_log_group[0].name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 4318
          hostPort      = 4318
        },
        {
          containerPort = 4317
          hostPort      = 4317
        },
        {
          containerPort = 13133
          hostPort      = 13133
        },
      ]
      environment = local.environment
    }
  ])
}