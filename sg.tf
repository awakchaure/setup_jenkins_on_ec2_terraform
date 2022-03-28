# Security Group
locals {
  ingressrules = [8080, 22]
}
resource "aws_security_group" "web_traffic" {
  name        = "allow_web_traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  vpc_id      = aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = local.ingressrules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

resource "aws_security_group" "private_ssh" {
  name        = "private-sg"
  description = "For SSH Connections to EC2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH Connections"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = aws_subnet.public_subnet.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}