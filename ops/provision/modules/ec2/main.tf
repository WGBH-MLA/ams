data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"]
# }

resource "aws_instance" "fcrepo" {
  for_each = {
    prod = "prod"
    demo = "demo"
    alpha = "alpha"
    bravo = "bravo"
    charlie = "charlie"
    delta = "delta"
  }

  ami                         = "ami-02538f8925e3aa27a" # data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = var.fcrepo_instance
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  tags = {
    "Name" = "${var.namespace}-fcrepo-${each.value}"
    "Role" = "fcrepo"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = 60
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = 60
    snapshot_id = var.fcrepo_snapshot != "" ? var.fcrepo_snapshot : null
    encrypted = true
    delete_on_termination = false
  }

  # Mounts isnt working so we write the fstab the old school way for now
  # echo "n" keeps the fs from being overwritten if it already exists
  user_data          =  templatefile("./modules/ec2/user_data.fcrepo.yaml", {
    var = {
      hostname = "${var.namespace}-fcrepo-${each.value}"
      keypair = var.keypair
      key_name = var.key_name
      fcrepo_db_hostname = var.fcrepo_db_hostname
      fcrepo_db_username = var.fcrepo_db_username
      fcrepo_db_password = var.fcrepo_db_password
      solr_collection = var.solr_collection
      site24x7_key = var.site24x7_key
      site24x7_group = var.site24x7_group
    }
  })
}
