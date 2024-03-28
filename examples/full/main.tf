module "aws_telemetry_stack" {
  source = "../.."
  create_adot_service = true
  create_prometheus = true
  create_workspace = true
  enable_internal_lb = true
  logging_configuration = []
  name = "my-otel-collector"
}