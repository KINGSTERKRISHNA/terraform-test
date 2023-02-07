resource "aws_instance" "ec2_instance" {
  ami           = "ami-084e8c05825742534"
  instance_type = local.instance_type
}
