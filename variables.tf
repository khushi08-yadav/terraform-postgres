variable "instance_count" {
    default=1
    type   = number
}

variable "instance_type"{
    default="c7i-flex.large"
    type   =string
}

variable "ec2_ami_id"{
    default="ami-0e5497a77ef21b5ac"
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
