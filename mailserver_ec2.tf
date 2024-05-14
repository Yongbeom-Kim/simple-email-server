data "aws_ami" "ami_with_docker" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # Amazon Linux 2023 AMI
  filter {
    name = "name"
    # values = ["al2023-ami-2023.4.20240513.0-kernel-6.1-x86_64"]
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
  }

  filter {
    name   = "owner-id"
    values = ["137112412989"] # amazon
  }

}

resource "aws_instance" "mail_server" {
  ami                         = data.aws_ami.ami_with_docker.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  security_groups = [
    aws_security_group.allow_all_local.id,
    aws_security_group.allow_ec2_instance_connect.id,
    aws_security_group.allow_internet_access.id
  ]


  user_data = <<-EOF
              #!/bin/bash

              # Install Docker
              yum update -y
              yum install -y docker
              service docker start
              usermod -aG docker ec2-user
              chkconfig docker on

              # Mount Amazon EFS
              sudo yum install -y amazon-efs-utils
              mkdir /efs
              ${local.efs_mount_access_point_command}
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "${var.service_name}-mail-server"
  }
}

resource "aws_eip" "mail_server" {
  domain = "vpc"

  instance   = aws_instance.mail_server.id
  depends_on = [aws_internet_gateway.gw]
}