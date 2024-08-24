variable "nv_subnets" {
  type        = list(string)
  description = "NV Subnets"
  default     = ["10.1.0.0/28", "10.1.0.16/28", "10.1.0.96/28"]
}

variable "mumbai_subnets" {
  type        = list(string)
  description = "Mumbai Subnets"
  default     = ["10.2.0.0/28", "10.2.0.16/28"]
}

variable "nv_azs" {
  type        = list(string)
  description = "NV Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "mumbai_azs" {
  type        = list(string)
  description = "Mumbai Availability Zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

