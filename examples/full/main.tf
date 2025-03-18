module "aws_telemetry_stack" {
  source              = "../.."
  create_adot_service = true
  create_prometheus   = true
  create_workspace    = true
  enable_internal_lb  = true

  cluster = "s2s-staging-us-east-1"
  name    = "s2sCore"
  subnets = ["subnet-", "subnet-"]
  vpc_id  = ""

}
