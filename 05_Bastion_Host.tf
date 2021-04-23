# overview of steps to dynamically generate keypair for bastion

#resource "tls_private_key" "tfe_bastion" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

#resource "aws_key_pair" "generated_bastion_key" {
#  key_name   = "bastion-key"
#  public_key = tls_private_key.tfe_bastion.public_key_openssh
#}

#output "public_key" {
#  value = aws_key_pair.generated_bastion_key
#}


resource "aws_security_group" "sample-bh-sg" {
  name   = "bastion_host_security_group"
  vpc_id = aws_vpc.sample-vpc.id
  depends_on = [
    aws_vpc.sample-vpc
  ]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "sample-bastion-server" {
  ami                         = "ami-0742b4e673072066f"
  instance_type               = "t2.micro"
  key_name                    = "chase_schultz_pico_demo_key"
  subnet_id                   = aws_subnet.sample-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.sample-bh-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  depends_on = [
    aws_vpc.sample-vpc,
    aws_subnet.sample-public-subnet
  ]
  root_block_device {
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "BastionHost"
  }
}
