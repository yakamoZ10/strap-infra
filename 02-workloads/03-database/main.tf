locals {
  create = true

  project = "ultralinkk"

  number_of_db_servers = 1

  db_secret = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)

  default_tags = {
    Project     = local.project
    Environment = var.environment
    Training    = "devops-engineer-associate"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.project}-db"
  subnet_ids = data.terraform_remote_state.networking.outputs.db_server_subnets_ids

  tags = merge({ Name = "${local.project}-db" }, local.default_tags)
}

resource "aws_db_parameter_group" "this" {
  name   = "${local.project}-db"
  family = "postgres16"

    parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}
resource "aws_kms_key" "this" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge({ Name = "${local.project}-kms-key" }, local.default_tags)
}


resource "aws_db_instance" "this" {
  identifier                = "${local.project}-db"
  instance_class            = "db.t4g.micro"
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "16.3"
  username                  = "postgres"
  password                  = local.db_secret["DATABASE_PASSWORD"]
  db_name                   = "ultralinkk_db"
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [data.terraform_remote_state.networking.outputs.db_server_sg_id]
  parameter_group_name      = aws_db_parameter_group.this.name
  publicly_accessible       = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "${local.project}-db"
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.this.arn

  tags = merge({ Name = "${local.project}-db" }, local.default_tags)
}