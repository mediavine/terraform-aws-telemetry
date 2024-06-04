################################################################################
# Workspace
################################################################################

output "workspace_arn" {
  description = "Amazon Resource Name (ARN) of the workspace"
  value       = try(aws_prometheus_workspace.this[0].arn, "")
}

output "workspace_id" {
  description = "Identifier of the workspace"
  value       = try(aws_prometheus_workspace.this[0].id, "")
}

output "workspace_prometheus_endpoint" {
  description = "Prometheus endpoint available for this workspace"
  value       = try(aws_prometheus_workspace.this[0].prometheus_endpoint, "")
}


################################################################################
# Internal Load Balancer
################################################################################

output "lb_dns_name" {
  description = "DNS name of the internal load balancer"
  value       = try(aws_lb.this[0].dns_name, "")
}

output "lb_private_ipv4_address" {
  description = "Private ip of the internal load balancer"
  value       = try(aws_lb.this[0].private_ipv4_address, "")
}