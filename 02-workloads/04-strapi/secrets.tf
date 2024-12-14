# TO DO: Add host, port, db in aws secret
resource "aws_secretsmanager_secret" "this" {
  name        = "${var.environment}/${local.project}/strapi"
  description = "Ultralink strapi Client Environment Variables"

  tags = merge({ Name = "${var.environment}/${local.project}/strapi" }, local.default_tags)
}

resource "aws_secretsmanager_secret_policy" "this" {
  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = data.aws_iam_policy_document.strapi_secret_policy.json
}

data "aws_iam_policy_document" "strapi_secret_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.strapi.arn]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.this.arn]
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    
    DATABASE_CLIENT    = "postgres"
    DATABASE_HOST      = "${data.terraform_remote_state.db.outputs.db_server_instance_endpoint}"
    DATABASE_PORT      = "5432"
    DATABASE_NAME      = "ultralinkk_db"
    DATABASE_USERNAME  = "postgres"
    DATABASE_PASSWORD  = ""
    JWT_SECRET         = ""
    ADMIN_JWT_SECRET   = ""
    APP_KEYS           = ""
    NODE_ENV           = "PRODUCTION"
  })
}