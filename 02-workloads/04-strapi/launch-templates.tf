
resource "aws_iam_role" "strapi" {
  name = "${local.project}-strapi-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${local.project}-strapi-role" }, local.default_tags)

}

resource "aws_iam_role_policy_attachment" "strapi_role_attach" {
  role       = aws_iam_role.strapi.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "${local.project}-strapi-ecr-policy"
  path        = "/"
  description = "ECR Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:Get*",
          "ecr:BatchGet*",
          "ecr:List*",
          "ecr:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  tags = merge({ Name = "${local.project}-strapi-ecr-policy" }, local.default_tags)
}

resource "aws_iam_role_policy_attachment" "erc_policy_attach" {
  role       = aws_iam_role.strapi.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_instance_profile" "strapi_server_instance_profile" {
  name = "${local.project}-strapi-instance-profile"
  role = aws_iam_role.strapi.name

  tags = merge({ Name = "${local.project}-strapi-instance-profile" }, local.default_tags)
}


# Launch template for EC2 instances (strapi servers)
resource "aws_launch_template" "strapi_server_lt" {
  name        = "strapi-server-lt"
  description = "A launch template for EC2 instances"


  # Instance details
  instance_type = "t3.small" # Change to your desired instance type

  # AMI ID
  image_id = "ami-08ec94f928cf25a9d"

  vpc_security_group_ids = [data.terraform_remote_state.networking.outputs.strapi_server_sg_id]

  # Key pair
  #   key_name = aws_key_pair.strapi_server.key_name

  # Optional: Block device mappings (e.g., to define volumes)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  # TO DO: Update user data to install all software packages required to run strapi client 
  user_data = base64encode(file("${path.module}/user_data.sh"))


  # Optional: Specify instance monitoring (e.g., enable CloudWatch detailed monitoring)
  monitoring {
    enabled = true
  }

  # Optional: IAM Instance Profile
  iam_instance_profile {
    name = aws_iam_instance_profile.strapi_server_instance_profile.name
  }

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ Name = "strapi-server" }, local.default_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge({ Name = "strapi-server" }, local.default_tags)
  }

  tags = merge({ Name = "strapi-server-lt" }, local.default_tags)
}