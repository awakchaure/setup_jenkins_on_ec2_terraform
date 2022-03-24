
variable "ingressrules" {
  type    = list(number)
  default = [8080, 22]
}

variable "ami_id" {
  default = "ami-018d50b368e796499"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "region" {
  default = "us-east-1"
}