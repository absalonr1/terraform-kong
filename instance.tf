/* resource "aws_eip" "eip_kong_bastion" {

  instance   = aws_instance.kong_bastion.id
  vpc        = true
  depends_on = [aws_internet_gateway.igw_kong]
} */

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

resource "aws_instance" "kong_vm_1" {
  ami                         = var.ami[var.region][var.environment]
  instance_type               = var.instance_type[var.environment] #"t2.micro"
  #associate_public_ip_address = true
  #key_name - (Optional) Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource.
  key_name        = var.key_pair
  security_groups = [aws_security_group.sg_kong.id]
  subnet_id       = aws_subnet.subnet_kong_1.id

#  user_data = templatefile("user_data-no_bd.tpl",{})
  user_data = templatefile("user_data.tpl",{
        db_ip = aws_db_instance.kong_bd.address, 
        db_pg_database=var.kong_db, 
        db_pg_user=var.kong_db_username, db_pg_password=var.kong_db_password }
        ) 

 depends_on = [aws_db_instance.kong_bd]

  tags = {
    Name = "kong_vm_1"
  }

}

resource "aws_instance" "kong_vm_2" {
  ami                         = var.ami[var.region][var.environment]
  instance_type               = var.instance_type[var.environment] #"t2.micro"
  #associate_public_ip_address = true
  #key_name - (Optional) Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource.
  key_name        = var.key_pair
  security_groups = [aws_security_group.sg_kong.id]
  subnet_id       = aws_subnet.subnet_kong_2.id

#  user_data = templatefile("user_data-no_bd.tpl",{})
  user_data = templatefile("user_data.tpl",{
        db_ip = aws_db_instance.kong_bd.address, 
        db_pg_database=var.kong_db, 
        db_pg_user=var.kong_db_username, db_pg_password=var.kong_db_password }
        ) 

 depends_on = [aws_db_instance.kong_bd]

  tags = {
    Name = "kong_vm_2"
  }

}

resource "aws_instance" "kong_bastion" {
  ami                         = var.ami[var.region][var.environment]
  instance_type               = var.instance_type[var.environment] #"t2.micro"
  associate_public_ip_address = true
  #key_name - (Optional) Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource.
  key_name        = var.key_pair
  security_groups = [aws_security_group.sg_kong_bastion.id]
  subnet_id       = aws_subnet.subnet_lbaas_1.id

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
  description = ""
  value       = aws_instance.kong_bastion.public_ip
}


/*
output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       =   aws_instance.kong_vm_2.public_ip
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.kong_vm_2.private_dns
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.kong_vm_2.private_ip
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.kong_vm_2.public_dns
}
*/


