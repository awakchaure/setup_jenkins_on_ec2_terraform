
//Create KEY
resource "tls_private_key" "keyt1" {
  algorithm = "RSA"
}
resource "aws_key_pair" "key" {
  key_name   = "keyt1"
  public_key = tls_private_key.keyt1.public_key_openssh
  depends_on = [
    tls_private_key.keyt1
  ]
}



//Create AWS Instance

resource "aws_instance" "jenkins_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key.key_name
  security_groups = [aws_security_group.web_traffic.id, aws_security_group.private_ssh.id]
  subnet_id       = aws_subnet.public_subnet.id
  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }
  delete_on_termination = false

  user_data = <<EOF
        echo "installing ansible"
        sudo amazon-linux-extras install java-openjdk11 -y
        sudo yum -y install wget
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo yum upgrade -y
        sudo yum install jenkins -y
        sudo systemctl start jenkins

        echo "installing ansible"
        sudo yum install python3
        python3 -m pip install --user ansible
  EOF
  tags = {
    Name = "jenkins_server"
  }
}


resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = "us-east-1b"
  size              = 20
  tags = {
    Name = "jenkins-ebs"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdd"
  volume_id    = aws_ebs_volume.ebs_volume.id
  instance_id  = aws_instance.jenkins_server.id
  force_detach = true
}

// instance in private subnet to deploy application
resource "aws_instance" "application_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key.key_name
  security_groups = [aws_security_group.web_traffic.id]
  subnet_id       = aws_subnet.private_subnet.id

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }
  tags = {
    Name = "application_server"
  }
}
