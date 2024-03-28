variable "create_prometheus" {
  description = "Determines whether a resources will be created"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

################################################################################
# Workspace
################################################################################

variable "create_workspace" {
  description = "Determines whether a workspace will be created or to use an existing workspace"
  type        = bool
  default     = true
}

variable "workspace_id" {
  description = "The ID of an existing workspace to use when `create_workspace` is `false`"
  type        = string
  default     = ""
}

variable "workspace_alias" {
  description = "The alias of the prometheus workspace. See more in the [AWS Docs](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-create-workspace.html)"
  type        = string
  default     = null
}

variable "logging_configuration" {
  description = "The logging configuration of the prometheus workspace."
  type        = map(string)
  default     = {}
}

################################################################################
# Alert Manager Definition
################################################################################

variable "alert_manager_definition" {
  description = "The alert manager definition that you want to be applied. See more in the [AWS Docs](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alert-manager.html)"
  type        = string
  default     = <<-EOT
    alertmanager_config: |
      route:
        receiver: 'default'
      receivers:
        - name: 'default'
  EOT
}

################################################################################
# Rule Group Namespace
################################################################################

variable "rule_group_namespaces" {
  description = "A map of one or more rule group namespace definitions"
  type        = map(any)
  default     = {}
}

################################################################################
# Load Balancer
################################################################################

variable "enable_internal_lb" {
  description = "Determines whether an internal load balancer will be created"
  type        = bool
  default     = false  
}

variable "name" {
  description = "The name of the load balancer"
  type        = string
  default = "adot"
}

variable "security_groups" {
  description = "A list of security group IDs to associate with the load balancer"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "A list of subnet IDs to associate with the load balancer"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the load balancer"
  type        = string
  default     = ""
}
################################################################################
# ECS
################################################################################
variable "create_adot_service" {
  description = "Determines whether the ECS service will be created"
  type        = bool
  default     = false
}

variable "cluster" {
  description = "The name of the ECS cluster"
  type        = string
  default     = ""
}

variable "otel_collector_image" {
  description = "The image of the otel collector"
  type        = string
  default     = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
  # https://gallery.ecr.aws/aws-observability/aws-otel-collector
}

variable "otel_collector_cpu" {
  description = "The CPU units to reserve for the otel collector"
  type        = number
  default     = 32
}

variable "otel_collector_memory" {
  description = "The memory to reserve for the otel collector"
  type        = number
  default     = 256
}

variable "adot_collector_command" {
  description = "The command to run the otel collector"
  type        = string
  default     = "--config=/etc/ecs-amp-xray.yaml"
}

