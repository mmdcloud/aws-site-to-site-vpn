variable "azs" {}

variable "subnets" {}

variable "cidr" {}

variable "region_name" {}

variable "user_data" {}

variable "key_pair" {
  description = "The name of the key pair to use for SSH access to instances."
  type        = string
}