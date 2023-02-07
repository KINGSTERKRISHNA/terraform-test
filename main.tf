resource "aws_eip" "lb" {
  vpc      = true
}

output "eip" {
  value = aws_eip.lb.id
}

resource "aws_instance" "first" {
  ami = "ami-084e8c05825742534"
  instance_type = "t2.micro"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.first.id
  allocation_id = aws_eip.lb.id
}

resource "aws_security_group" "allow_tls" {
  name        = "kingsterlabs-sg"
  description = "Allow TLS inbound traffic"

  ingress { #inbound
    description = "testing"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
    #cidr_blocks = ["${aws_eip.lb.public_ip}/32"] #we are adding "${}" since we combining attribute with /32
  }                               #till .11 this was standard, but from .12 onwards it is used in rare cases like this

  ingress { #inbound
    description = "testing"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }

  ingress { #inbound
    description = "testing"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }

  egress { #outbound
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "testing kingsterlab"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.allow_tls.id
  network_interface_id = aws_instance.first.primary_network_interface_id
}
