module "aws_telemetry_stack" {
  source = "../.."

  create_otel_collector_service = true
  enable_internal_lb            = true
  desired_count                 = 1
  cluster                       = "sample-infra-main-ecs-cluster"
  name                          = "terraform"
  subnets                       = ["subnet-2edfbe0f", "subnet-81dff5cc"]
  vpc_id                        = "vpc-03cd7b7e"
  otel_collector_cpu            = 4096
  otel_collector_memory         = 8192
  otel_collector_image          = "otel/opentelemetry-collector-contrib:0.106.1"
  region                        = "us-east-1"

  custom_otel_config = [
    {
      otel_config_file_path = "config/otel-collector-config.yaml"
    }
  ]

  custom_otel_secrets = ["INFLUXDB_TOKEN"]

  autoscaling_configuration = [{
    max_capacity           = 100
    min_capacity           = 6
    cpu_threshold_value    = 70
    memory_threshold_value = 70
    scale_in_cooldown      = 300
    scale_out_cooldown     = 0
  }]

}
