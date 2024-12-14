
resource "aws_ecr_repository" "strapi" {
  count                = local.create ? 1 : 0
  name                 = "ultralinkk/strapi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge({ Name = "ultralinkk/strapi" }, local.default_tags)
}