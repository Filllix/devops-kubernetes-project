data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "ansible" {
  key_name   = "${var.project_name}-ansible-key"
  public_key = var.ansible_ssh_public_key

  tags = {
    Name        = "${var.project_name}-ansible-key"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "ansible_host" {
  name        = "${var.project_name}-ansible-host-sg"
  description = "Security group for Ansible management host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from administrator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ansible_ssh_cidr]
  }

  ingress {
    description = "Nginx test access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.ansible_ssh_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ansible-host-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "ansible_host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ansible_host.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ansible.key_name

  iam_instance_profile = aws_iam_instance_profile.ansible_host.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-ansible-management-host"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
