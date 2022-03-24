
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
  key_name        = "aws_key_pair.key.key_name"
  security_groups = ["allow_web_traffic"]

  provisioner "remote-exec" {
    connection {
      agent       = "false"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.keyt1.private_key_pem}"
      host        = "${aws_instance.jenkins_server.public_ip}"
    }
    inline = [
      "sudo yum install -y java-11-openjdk-devel",
      "sudo yum -y install wget",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum upgrade -y",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
    ]
  }
  tags = {
    Name = "jenkins_server"
  }
}