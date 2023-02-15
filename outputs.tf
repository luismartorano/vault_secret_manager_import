output "message" {
  description = "Success Message"
  value       = "Successfully copied over secrets from AWS Secrets Manager to HashiCorp Vault! Here are the secret names and paths below:"
}

output "secrets_in_vault" {
  description = "Names and paths of Secrets in Vault"
  value       = [for path_name in vault_generic_secret.mysecret_in_vault : path_name.path]
}
