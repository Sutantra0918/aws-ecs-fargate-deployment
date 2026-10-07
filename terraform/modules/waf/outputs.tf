output "web_acl_Arn" {
  description = "WAF web acl ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_id" {
  description = "WAF web ACI ID"
  value       = aws_wafv2_web_acl.main.id
}