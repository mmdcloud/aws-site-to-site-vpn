# output "mumbai_vm_private_ip" {
#   value = module.mumbai-resources.private_ip  
# }

# output "nv_vm_private_ip" {
#   value = module.nv-resources.private_ip  
# }

# Output the public IPs of the instances
output "vm1_public_ip" {
  value = aws_instance.vm1.public_ip
}

output "vm2_public_ip" {
  value = aws_instance.vm2.public_ip
}