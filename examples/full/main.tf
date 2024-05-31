module "aws_telemetry_stack" {
  source              = "../.."
  create_adot_service = true
  create_prometheus   = true
  create_workspace    = true
  enable_internal_lb  = true

  cluster = "s2s-staging-us-east-1"
  name    = "s2sCore"
  subnets = ["subnet-09246dccc92094d78", "subnet-09b4bdae02c946dfb"]
  vpc_id  = "vpc-05323c72071982c4d"

}