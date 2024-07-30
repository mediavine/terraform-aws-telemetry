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
  default     = "adot"

  validation {
    condition     = length(var.name) <= 9
    error_message = "The name must b3 no more than 9 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9]*$", var.name))
    error_message = "The name must contain only alphanumeric characters."
  }
}

# variable "security_groups" {
#   description = "A list of security group IDs to associate with the load balancer"
#   type        = list(string)
#   default     = []
# }

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

variable "adot_collector_image" {
  description = "The image of the otel collector"
  type        = string
  default     = "public.ecr.aws/aws-observability/aws-otel-collector:v0.38.1"
  # https://gallery.ecr.aws/aws-observability/aws-otel-collector
}

variable "otel_collector_image" {
  description = "The image of the otel collector"
  type        = string
  default     = "otel/opentelemetry-collector-contrib:0.87.0"
}

variable "otel_collector_cpu" {
  description = "The CPU units to reserve for the otel collector"
  type        = number
  default     = 512
}

variable "otel_collector_memory" {
  description = "The memory to reserve for the otel collector"
  type        = number
  default     = 1024
}

variable "adot_collector_command" {
  description = "The command to run the otel collector"
  type        = string
  default     = "--config=/etc/ecs/ecs-amp-xray.yaml"
}

variable "amazon_prometheus_endpoint" {
  description = "The endpoint of the prometheus workspace"
  type        = string
  default     = null
}

variable "amazon_prometheus_endpoint_region" {
  description = "The region of the prometheus workspace"
  type        = string
  default     = "us-east-1"

}

variable "create_otel_collector_service" {
  description = "If true creates ecs service for otel-collector-contrib"
  type        = bool
  default     = false
}

variable "custom_otel_config" {
  type = list(object({
    otel_config_file_path = string
  }))
  default = [{
    otel_config_file_path = null
  }]
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 3
}

variable "autoscaling_configuration" {
  type = list(object({
    min_capacity           = number
    max_capacity           = number
    cpu_threshold_value    = number
    memory_threshold_value = number
    scale_in_cooldown      = number
    scale_out_cooldown     = number
  }))

  description = "The autoscaling configuration"
  default = [
    {
      min_capacity           = 3
      max_capacity           = 10
      cpu_threshold_value    = 50
      memory_threshold_value = 50
      scale_in_cooldown      = 300
      scale_out_cooldown     = 300
    }
  ]
}