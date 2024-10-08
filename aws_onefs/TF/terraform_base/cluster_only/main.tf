# uses existing IAM profile, int-sg and ext-sg that have been precreated
# with hashed credentials 



module "onefs" {
  source  = "dell/onefs/aws"
  version = "1.0.0"
   availability_zone = "us-east-1b"
   iam_instance_profile = "777777777777777-powerscale-node-runtime-instance-profile"
   name = "vonefs-tf1"
   id = "vonefs-tf1"
   nodes = 4
   instance_type = "m5dn.8xlarge"
   data_disk_type = "gp3"
   data_disk_size = 1024
   data_disks_per_node = 5
   internal_subnet_id = "subnet-11111111111111111"
   external_subnet_id = "subnet-22222222222222222"
   internal_sg_id = "sg-11111111111111"
   security_group_external_id = "sg-2222222222222"
   image_id = "ami-05b474855849ccfd7"
   credentials_hashed = true
   hashed_root_passphrase = "$5$9874f5d2c724b8ca$IFZZ5e9yfUVqNKVL82s.iFLIktr4WLavFhUVa8A"
   hashed_admin_passphrase = "$5$9874f5d2c724b8ca$IFZZ5e9yfUVqNKVL82s.iFLIktr4WLavFhUVa8A"
}
