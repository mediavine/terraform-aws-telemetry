locals {
  workspace_id = var.create_prometheus && var.create_workspace ? aws_prometheus_workspace.this[0].id : var.workspace_id
  
  # if this is true, then this will error
  # only one otel collector service at a time
  # validation is added to the variable "validate_otel_collector_service"
  ecs_service_validator = !(var.create_adot_service && var.create_otel_collector_service)
}

################################################################################
# Workspace
################################################################################

resource "aws_prometheus_workspace" "this" {
  count = var.create_prometheus && var.create_workspace ? 1 : 0

  alias = var.workspace_alias

  dynamic "logging_configuration" {
    for_each = length(var.logging_configuration) > 0 ? [var.logging_configuration] : []

    content {
      log_group_arn = logging_configuration.value.log_group_arn
    }
  }

  tags = var.tags
}

################################################################################
# Alert Manager Definition
################################################################################

resource "aws_prometheus_alert_manager_definition" "this" {
  count = var.create_prometheus ? 1 : 0

  workspace_id = local.workspace_id
  definition   = var.alert_manager_definition
}

################################################################################
# Rule Group Namespace
################################################################################

resource "aws_prometheus_rule_group_namespace" "this" {
  for_each = var.create_prometheus ? var.rule_group_namespaces : {}

  name         = each.value.name
  workspace_id = local.workspace_id
  data         = each.value.data
}