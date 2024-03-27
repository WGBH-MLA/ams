// SG to allow SSH connections from anywhere
resource "aws_security_group" "access" {
  name        = "${var.namespace}-access"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    cidr_blocks      = [
      "18.205.248.83/32",
    ]
    description      = "AMS2 on digital-eks-dev cluster"
    from_port        = 8080
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 8080
  }

  ingress {
    cidr_blocks      = [
      "18.205.248.83/32",
    ]
    description      = "AMS2 on digital-eks-dev cluster"
    from_port        = 8983
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 8983
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-access"
  }
}
