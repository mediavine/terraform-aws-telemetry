resource "aws_ecs_service" "adot_ecs_service" {
  count = var.create_adot_service ? 1 : 0

  name            = "${var.name}-otel-collector"
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.adot_task_definition[0].arn
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

resource "aws_cloudwatch_log_group" "adot_service_log_group" {
  count = var.create_adot_service ? 1 : 0

  name              = "/ecs/${var.name}-otel-collector"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "adot_task_definition" {
  count = var.create_adot_service ? 1 : 0

  family                   = "${var.name}-otel-collector"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.otel_collector_cpu
  memory                   = var.otel_collector_memory
  execution_role_arn       = aws_iam_role.execution_role[0].arn
  task_role_arn            = aws_iam_role.task_role[0].arn

  container_definitions = jsonencode([
    {
      name      = "otel-collector"
      image     = var.adot_collector_image
      cpu       = var.otel_collector_cpu
      memory    = var.otel_collector_memory
      essential = true
      command   = [var.adot_collector_command]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.adot_service_log_group[0].name
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
      environment = [
        {
          name  = "AWS_PROMETHEUS_ENDPOINT"
          value = var.amazon_prometheus_endpoint == null ? "${aws_prometheus_workspace.this[0].prometheus_endpoint}api/v1/remote_write" : "${var.amazon_prometheus_endpoint}api/v1/remote_write"
        },
        {
          name  = "AWS_REGION"
          value = var.amazon_prometheus_endpoint_region
        }
      ]
    }
  ])
}
