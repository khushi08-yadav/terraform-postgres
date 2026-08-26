module "ec2" {

source        = "./module-postgres"
instance_count=1
instance_type ="c7i-flex.large"
ec2_ami_id    ="ami-0e5497a77ef21b5ac" #ubuntu

}
