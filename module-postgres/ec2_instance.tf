# key pair(login)

resource "aws_key_pair" "my_ec2_key"{

  key_name   =var.ec2_key_name
  public_key = file("${path.root}/terra-k8s-key.pub")
}

# vpc and security group
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "k8s-automate-sg"
  description = "Security group for k8s cluster with argocd and postgreSQL"
  vpc_id      = aws_default_vpc.default.id #interpolation
  # inbound rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description ="SSH Access"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description ="HTTP Access"
  }
  ingress{
    from_port   =443
    to_port     =443
    protocol    ="tcp"
    cidr_blocks =["0.0.0.0/0"]
    description ="HTTPS Access (Argocd web ui)"
  }
  ingress{
    from_port   =6443
    to_port     =6443
    protocol    ="tcp"
    cidr_blocks =["0.0.0.0/0"]
    description ="k8s API server"
   }

  #outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "k8s-autoamte-sg"
  }

}
# EC2 instance 
resource "aws_instance" "my_ec2" {
  count           =var.instance_count
  depends_on      = [aws_security_group.allow_ssh, aws_key_pair.my_ec2_key]
  ami             = var.ec2_ami_id
  key_name        = aws_key_pair.my_ec2_key.key_name
  instance_type   = var.instance_type
  security_groups = [aws_security_group.allow_ssh.name]
  user_data       =file("${path.module}/install-k8s.sh")
  
  root_block_device {
    volume_size = var.root_block_device_volume_size
    volume_type = "gp3"
  }
  tags = {
    Name       = "k8s-ec2-instance"
}
}
