resource "aws_appautoscaling_target" "this" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  max_capacity       = var.autoscaling_configuration[0].max_capacity
  min_capacity       = var.autoscaling_configuration[0].min_capacity
  resource_id        = var.create_otel_collector_service ? "service/${var.cluster}/${aws_ecs_service.otel_collector_ecs_service[0].name}" : "service/${var.cluster}/${aws_ecs_service.adot_ecs_service[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_utilization" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name               = "${var.name}-otel-collector-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_configuration[0].cpu_threshold_value
    # amount of time, in seconds,
    # after a scale in or scale out activity has completed
    # where further scaling activities are suspended
    scale_in_cooldown  = var.autoscaling_configuration[0].scale_in_cooldown
    scale_out_cooldown = var.autoscaling_configuration[0].scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "memory_utilization" {
  count = var.create_adot_service || var.create_otel_collector_service ? 1 : 0

  name               = "${var.name}-otel-collector-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_configuration[0].memory_threshold_value
    # amount of time, in seconds,
    # after a scale in or scale out activity has completed
    # where further scaling activities are suspended
    scale_in_cooldown  = var.autoscaling_configuration[0].scale_in_cooldown
    scale_out_cooldown = var.autoscaling_configuration[0].scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
