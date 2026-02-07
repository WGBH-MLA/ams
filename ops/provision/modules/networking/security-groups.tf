// SG for EC2 instances (fcrepo/solr/postgres)
// Allows SSH from anywhere and service ports from the VPC (EKS pods)
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

  # PostgreSQL — allow EKS pods (VPC CIDR) to reach the database
  ingress {
    description = "PostgreSQL from VPC (EKS pods)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Fcrepo — allow EKS pods (VPC CIDR) to reach Fedora
  ingress {
    description = "Fcrepo from VPC (EKS pods)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Solr — allow EKS pods (VPC CIDR) to reach Solr
  ingress {
    description = "Solr from VPC (EKS pods)"
    from_port   = 8983
    to_port     = 8983
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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
