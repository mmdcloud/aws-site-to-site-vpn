module "nv-resources" {
  source      = "./regional-resources"
  azs         = var.nv_azs
  region_name = "nv"
  cidr        = "10.1.0.0/24"
  subnets     = var.nv_subnets
  user_data   = filebase64("${path.module}/../scripts/nv_user_data.sh")
  providers = {
    aws = aws.nv
  }
}

module "mumbai-resources" {
  source      = "./regional-resources"
  azs         = var.mumbai_azs
  region_name = "mumbai"
  cidr        = "10.2.0.0/24"
  user_data   = filebase64("${path.module}/../scripts/mumbai_user_data.sh")
  subnets     = var.mumbai_subnets
  providers = {
    aws = aws.mumbai
  }
}
