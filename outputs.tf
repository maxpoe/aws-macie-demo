output "unique_session_id_for_resources" {
  value = random_id.demo_unique-id.hex
}

output "resource_owner" {
  value = var.owner
}

output "sns_email" {
  value = var.email
}
