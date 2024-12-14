resource "aws_security_group" "strapi_server_sg" {
  name        = "strapi-server-sg"
  description = "Security group for strapi servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic on port 80 from the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "strapi-server-sg" }, local.default_tags)
}


resource "aws_security_group" "db_server_sg" {
  name        = "db-server-sg"
  description = "Security group for db servers"
  vpc_id      = aws_vpc.main.id

  # TO DO: Allow traffic only from api server sg
  ingress {
    description = "Allow inbound traffic on port 5432 from the VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "db-server-sg" }, local.default_tags)
}
