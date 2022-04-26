provider "aws" {
  region = var.region
}
/*
resource "aws_eip" "my_static_ip" {
  instance = aws_instance.SkillUpAMI.id
  tags     = var.commond_tags
}

*/
data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "SkillUpAMI" {
  ami           = data.aws_ami.latest_amazon_linux.id #Avazon Linux AMI
  instance_type = var.instance_type
  
  #------------------volume-----------------------------
  root_block_device {
    volume_size = "8"
    tags        = var.commond_tags
  }

  #-------------------security_group----------------------------
  #vpc_security_group_ids = [aws_security_group.SkillUpAMI.id]
  vpc_security_group_ids = ["sg-df9dfca6"] #Template SG
  #--------------------ssh---------------------------
  #key_name = "SergeyTreyman1" #ssh
  key_name = "sn" #ssh
  #-----------------------------------------------
  user_data = file("files/user_data.sh")
  tags = merge(
    var.commond_tags,
  { image   = "amzn2-ami-hvm" })
}
/**/
  #--------------------ssh-keygen---------------------------
resource "aws_key_pair" "sn" {
  key_name   = "sn"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9Awc4aXXqdcRvx44NnY1EHlFAAgtzyylr6jVMn5TcJkHXCkc0rfy7amyczAvaeA97o1Hwege01oy0Shanx+8xU7WZ1/ePufQyP3rElFT9OKZtB0N/uQDQfUnUM7RARp6dob5tM37UdpQGdTkB5IfYh0sEPO5gjxbYoVcBxgKhfb2MHnzO1ESGmx4vRZ3e6SbNyYtngRs0HSkZtrgNWpuzgocMtOEDe7M6PLNOnHa5cDyac/JJI7dTSYVbrcnSBnePIZsWrRigPlEZ2OjYmDkS0VeOuSBiwN91QEDBjTWBNbA6Npw2TQTq9wnAtTMuGFDgQtNZsMW439ULzGHex2PUml3ll47ygAmOxb6q2C8R8UBhVp3QVjeJSXu9PEE9ZI02mHHrkb2xia9lsq6M4XSZJy7pW5iz3KWYkw1A1OUKXQ1iMY4edUa6aW+HHlwv4Q267IgFOcfDPgo6BWwwY1+ZOLaU7b2uAGnX/+Pwr/2jVkKmzvHDlHhsjMbFaQ89Dkk= sn@BigDropSN"
}

/*  #-------------------security_group----------------------------
resource "aws_security_group" "SkillUpAMI" {
  name = "Dynamic Security Group"
  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["109.86.217.88/32"]
    description = "Sergey Treyman"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "SkillUpAMI"
    Billing = "internal"
    Owner   = "Sergey Treyman"
  }
}
  #-----------------------------------------------
*/
