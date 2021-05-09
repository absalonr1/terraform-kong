resource "aws_security_group" "sg_kong" {
  name   = "sg_kong_allow-all-sg"
  vpc_id = aws_vpc.kong_vpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 8001
    to_port   = 8001
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
    Name = "sg_kong"
  }
}

resource "aws_security_group" "sg_kong_bastion" {
  name   = "sg_kong_bastion"
  vpc_id = aws_vpc.kong_vpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
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
    Name = "sg_kong_bastion"
  }
}

resource "aws_instance" "kong_vm" {

  count = var.kong_vm_instance_count

  ami                         = var.ami[var.region][var.environment]
  instance_type               = var.instance_type[var.environment]
  key_name        = var.key_pair
  security_groups = [aws_security_group.sg_kong.id]

  subnet_id       = aws_subnet.subnet_kong[count.index % length(aws_subnet.subnet_kong)].id

  user_data = templatefile("user_data.tpl",{
        db_ip = aws_db_instance.kong_bd.address, 
        db_pg_database=var.kong_db, 
        db_pg_user=var.kong_db_username, db_pg_password=var.kong_db_password }
        ) 
 
 depends_on = [aws_db_instance.kong_bd]

  tags = {
    Name = "kong_vm_${count.index}"
  }

}

resource "aws_instance" "kong_bastion" {
  ami                         = var.ami[var.region][var.environment]
  instance_type               = var.instance_type[var.environment]
  associate_public_ip_address = true
  key_name        = var.key_pair
  security_groups = [aws_security_group.sg_kong_bastion.id]
  subnet_id       = aws_subnet.subnet_lbaas[0].id

   user_data = templatefile("user_data_bastion.tpl",{
        db_ip = aws_db_instance.kong_bd.address, 
        pg_admin_user=var.db_username, 
        pg_admin_password=var.db_password, 
        kong_bd_user=var.kong_db_username,
        kong_bd_user_pass=var.kong_db_password,
        kong_bd_name=var.kong_db
      }
    )
  
  depends_on = [aws_db_instance.kong_bd]

  tags = {
    Name = "kong_bastion"
  }

}

output "kong_bastion_public_ip" {
  description = "kong_bastion_public_ip"
  value       = aws_instance.kong_bastion.public_ip
}