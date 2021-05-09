
resource "aws_db_instance" "kong_bd" {
  publicly_accessible = true
  name                = "kongdb"
  allocated_storage    = 100
  db_subnet_group_name = "kong_bd_subnet_group"
  engine               = "postgres"
  engine_version       = var.db_engine_version
  identifier           = "kongdb"
  instance_class       = var.db_instance_type[var.environment]
  password             = var.db_password
  skip_final_snapshot  = true
  multi_az             = var.environment == "prod" ? true : false
  #storage_encrypted    = true
  username             = var.db_username
  depends_on            = [aws_db_subnet_group.kong_bd_subnet_group]
  vpc_security_group_ids = [aws_security_group.sg_kong_bd.id]
}

#Leeme: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.Subnets
resource "aws_db_subnet_group" "kong_bd_subnet_group" {
  name       = "kong_bd_subnet_group"
  subnet_ids = [aws_subnet.subnet_kong_1.id, aws_subnet.subnet_kong_2.id]
}

#output "subnet_group_id" {
#  value       = join("", aws_db_subnet_group.default.*.id)
#  description = "ID of the created Subnet Group"
#}


resource "aws_security_group" "sg_kong_bd" {
  name   = "sg_kong_bd"
  vpc_id = aws_vpc.kong_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_kong_bd"
  }
}


