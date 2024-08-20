module "nv-resources" {
  source      = "./regional-resources"
  azs         = var.nv_azs
  cidr        = "10.1.0.0/24"
  region_name = "nv"
  subnets     = var.nv_subnets
  providers = {
    aws = aws.nv
  }
}

module "mumbai-resources" {
  source      = "./regional-resources"
  azs         = var.mumbai_azs
  region_name = "mumbai"
  cidr        = "10.2.0.0/24"
  subnets     = var.mumbai_subnets
  providers = {
    aws = aws.mumbai
  }
}
