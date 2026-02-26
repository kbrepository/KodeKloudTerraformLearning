# -----------------------------
# 1) Get default VPC + default SG
# -----------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Optional but recommended: pick a subnet in the default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------
# 2) Create a new RSA key locally + upload public key to AWS as key pair
# -----------------------------
resource "tls_private_key" "datacenter_kp" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "datacenter_kp" {
  key_name   = "datacenter-kp"
  public_key = tls_private_key.datacenter_kp.public_key_openssh
}

# Save the private key locally so you can SSH later
# (File will be created where you run terraform)
resource "local_file" "datacenter_kp_pem" {
  filename        = "datacenter-kp.pem"
  content         = tls_private_key.datacenter_kp.private_key_pem
  file_permission = "0400"
}

# -----------------------------
# 3) EC2 instance
# -----------------------------
resource "aws_instance" "datacenter_ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.datacenter_kp.key_name

  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_id              = data.aws_subnets.default_vpc_subnets.ids[0]

  tags = {
    Name = "datacenter-ec2"
  }
}