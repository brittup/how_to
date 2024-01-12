module "onefs_ext-security-group" {
  source  = "dell/onefs/aws//modules/ext-security-group"
  version = "1.0.0"
  vpc_id = "vpc-77777777777777777"
  external_cidr_block = "X.X.X.X/24"
  gateway_hostnum = "01"
  cluster_id = "tf1"
}