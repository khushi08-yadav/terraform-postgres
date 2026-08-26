variable "instance_count" {
    description= "This is the no. of ec2 instance"
    type       = number
}

variable "instance_type"{
    description="This is instance type for postgres ec2"
    type   =string
}

variable "ec2_ami_id"{
    default="This is the instance ami id for postgres ec2"
    type   =string
}

variable "ec2_key_name" {
  default = "terra-k8s-key"
  type    = string
}

variable "root_block_device_volume_size" {
  default = 30
  type    = number
}

