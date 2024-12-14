locals {
  create = true

  project = "ultralinkk"

  github_org_url = "https://github.com/yakamozo10"

  github_repositories = local.create ? [
    {
      name : "yakamozo10/strapi-infra",
      policy : {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "vpc:*",
              "ec2:*",
              "ecr:*",
              "iam:*",
              "rds:*",
              "ssm:*",
              "autoscaling:*",
              "cloudwatch:*",
              "secretsmanager:*",
              "acm:*",
              "kms:*",
              "route53:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
          {
            Action = [
              "s3:PutObject",
              "s3:Describe*",
              "s3:Get*",
              "s3:List*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
            { Action = [
                "elasticloadbalancing:*"
            ]
            Effect = "Allow"
            Resource = "*"
          },
            { Action = [
              "dynamodb:Describe*",
              "dynamodb:Get*",
              "dynamodb:PutItem",
              "dynamodb:DeleteItem",
              "dynamodb:UpdateItem"
           ]
            Effect   = "Allow"
            Resource = "arn:aws:dynamodb:eu-central-1:340752798883:table/ultralinkk-terraform-lock"
          },

        ]
      }
    },

  ] : []

  default_tags = {
    Project     = local.project
    Environment = var.environment
    Training    = "devops-engineer-associate"
  }
}

// OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  count           = local.create ? 1 : 0
  client_id_list  = [local.github_org_url, "sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint]
  url             = "https://token.actions.githubusercontent.com"

  tags = merge({ Name = "GitHub OIDC Provider" }, local.default_tags)
}


data "aws_iam_policy_document" "assume_role" {
  for_each = { for t in local.github_repositories : t.name => t }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test = "StringLike"
      values = [
        "repo:${each.value.name}:*"
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }

    condition {
      test = "StringLike"
      values = [
        "sts.amazonaws.com"
      ]
      variable = "token.actions.githubusercontent.com:aud"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
      type        = "Federated"
    }
  }



  version = "2012-10-17"
}

resource "aws_iam_role" "this" {
  for_each = { for t in local.github_repositories : t.name => t }

  name                 = "github-${split("/", each.value.name)[1]}-role-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role[each.key].json
  description          = "Role assumed by the GitHub OIDC provider."
  max_session_duration = 3600
  path                 = "/"
}

resource "aws_iam_policy" "this" {
  for_each = { for t in local.github_repositories : t.name => t }

  name        = "github-${split("/", each.value.name)[1]}-policy-${var.environment}"
  description = "Policy used by the GitHub role."
  path        = "/"
  policy      = jsonencode(each.value.policy)
}

resource "aws_iam_policy_attachment" "this" {
  for_each = { for t in local.github_repositories : t.name => t }

  name       = "github-${split("/", each.value.name)[1]}-policy-attachment"
  roles      = [aws_iam_role.this[each.key].name]
  policy_arn = aws_iam_policy.this[each.key].arn
}
