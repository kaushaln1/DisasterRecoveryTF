terraform {
  backend "s3" {
    bucket = "disasterrecoverytfstates"
    key    = "tfstates"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.secondary_region
}

#instance ec2 secondary
resource "aws_instance" "secondary_instance" {
  provider = aws.secondary
  ami      = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.secondary_subnet_1.id
}
# Create the DB instance in the secondary region
resource "aws_db_instance" "failover_db" {
  allocated_storage       = 20
  instance_class       = "db.t3.micro"
  engine                  = "mysql"
  username         = "foo"
  password         = "bar"
  snapshot_identifier     = var.snapshot_id
}

# Update EC2 instances to full capacity in the secondary environment
resource "aws_autoscaling_group" "secondary_asg" {
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  vpc_zone_identifier = [aws_subnet.secondary_subnet_1.id , aws_subnet.secondary_subnet_2.id]

  # Other required parameters here...
}

output "failover_db_endpoint" {
  value = aws_db_instance.failover_db.endpoint
}

output "secondary_instance_id" {
  value = aws_instance.secondary_instance.id
}