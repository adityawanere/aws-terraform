# Creates Virtual Private Cloud (Vnet)
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

# Creates Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main IGW"
  }
}

# Creates a Network Security Group
resource "aws_security_group" "react_site_sec_grp" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Linux Site"
  }
}

# Creates HTTP inbound rule
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.react_site_sec_grp.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# Creates HTTPS inbound rule
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.react_site_sec_grp.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# Creates SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.react_site_sec_grp.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.react_site_sec_grp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Creates a Subnet
resource "aws_subnet" "react_site_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/26"
  map_public_ip_on_launch = true
  tags = {
    Name = "Linux Site"
  }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Main Route Table"
  }
}

# Associate the Route Table with Subnet
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.react_site_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Create an IAM Role that EC2 can assume
resource "aws_iam_role" "ssm_role" {
  name = "ec2_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

# Attach the SSM managed policy to the IAM role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Create an instance profile (needed to associate IAM role with EC2)
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ssm_role.name
}


# Creates Linux EC2 instance
resource "aws_instance" "react_site_ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.react_site_subnet.id
  vpc_security_group_ids      = [aws_security_group.react_site_sec_grp.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "React-Site"
  }
}

# Store EC2 Instance ID
resource "aws_ssm_parameter" "react_site_ec2_instance_id" {
  name  = "/devops/react-site-ec2-instance-id"
  type  = "String"
  value = aws_instance.react_site_ec2_instance.id
  tags = {
    Name = "React-Site"
  }
}

resource "aws_ecr_repository" "my_ecr_registry" {
  name                 = "react-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "React-Site"
  }
}

