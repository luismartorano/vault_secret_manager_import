provider "aws" {
  region = var.aws_region
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
