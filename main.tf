provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.9.1"
    }
  }
}

module "secretsmanager-to-vault-migration" {
  source  = "samgabrail/secretsmanager-to-vault-migration/vault"
  version = "0.0.4" # use the latest version or pin a version
  # insert at least the 1 required variable here
  secret_names = ["samg-migration-vault", "samg-migration-vault2"]
}



data "aws_secretsmanager_secret" "mysecret" {
  for_each = toset(var.secret_names)
  name     = each.value
}

data "aws_secretsmanager_secret_version" "mysecret" {
  for_each  = toset(var.secret_names)
  secret_id = data.aws_secretsmanager_secret.mysecret[each.value].id
}

resource "vault_generic_secret" "mysecret_in_vault" {
  for_each  = toset(var.secret_names)
  path      = "${var.vault_kv_path}/${each.value}"
  namespace = var.vault_namespace
  data_json = data.aws_secretsmanager_secret_version.mysecret[each.value].secret_string
}
