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

variable "mumbai_user_data" {
  type    = string
  default = <<EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    
    sudo su
    apt-get install openswan -y
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
    service network restart

    chkconfig ipsec on
    service ipsec start
    service ipsec status
    service ipsec restart
    EOF
}

variable "nv_user_data" {
  type    = string
  default = <<EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
  EOF
}
