# Key Pair
data "aws_key_pair" "my_ec2_key" {
  key_name = var.ec2_key_name
}

# Default VPC
resource "aws_default_vpc" "default" {
}

# Existing Security Group
data "aws_security_group" "allow_ssh" {
  filter {
    name   = "group-name"
    values = ["k8s-automate-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# EC2 Instance
resource "aws_instance" "my_ec2" {
  count         = var.instance_count
  ami           = var.ec2_ami_id
  key_name      = data.aws_key_pair.my_ec2_key.key_name
  instance_type = var.instance_type

  security_groups = [data.aws_security_group.allow_ssh.name]

  user_data = file("${path.module}/install-k8s.sh")

  root_block_device {
    volume_size = var.root_block_device_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "k8s-ec2-instance"
  }
}
