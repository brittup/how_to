module "onefs_int-security-group" {
  source  = "dell/onefs/aws//modules/int-security-group"
  version = "1.0.0"
  network_id = "vpc-77777777777777"
  id = "tf1"
}