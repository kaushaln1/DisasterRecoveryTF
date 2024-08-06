provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# Primary infrastructure
resource "aws_vpc" "primary_vpc" {
  provider  = aws.primary
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "primary_subnet_1" {
  provider  = aws.primary
  vpc_id    = aws_vpc.primary_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "primary_subnet_2" {
  provider  = aws.primary
  vpc_id    = aws_vpc.primary_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_instance" "primary_instance" {
  provider     = aws.primary
  ami          = var.ami_id
  instance_type = var.instance_type
  subnet_id    = aws_subnet.primary_subnet_1.id
}


resource "aws_db_instance" "primary_db" {
  provider             = aws.primary
  allocated_storage    = 20
  instance_class        = "db.t3.micro"
  engine               = "mysql"
  username            = "admin"
  password              = "password123"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  db_subnet_group_name = aws_db_subnet_group.primary_subnet_group.name
}


resource "aws_security_group" "primary_sg" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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


resource "aws_db_subnet_group" "primary_subnet_group" {
  provider  = aws.primary
  name      = "primary-db-subnet-group"
  subnet_ids = [aws_subnet.primary_subnet_1.id, aws_subnet.primary_subnet_2.id]
}





resource "aws_vpc" "secondary_vpc" {
  provider = aws.secondary
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "secondary_subnet_1" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"
}


resource "aws_subnet" "secondary_subnet_2" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-west-2c"
}


resource "aws_db_subnet_group" "secondary_subnet_group" {
  provider  = aws.secondary
  name      = "secondary-db-subnet-group"
  subnet_ids = [aws_subnet.secondary_subnet_1.id, aws_subnet.secondary_subnet_2.id]
}

output "primary_instance_id" {
  value = aws_instance.primary_instance.id
}


output "primary_db_endpoint" {
  value = aws_db_instance.primary_db.endpoint
}
