output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}

output "ssh_private_key_pem" {
  value = tls_private_key.keyt1.private_key_pem
}

output "ssh_public_key_pem" {
  value = tls_private_key.keyt1.public_key_pem
}