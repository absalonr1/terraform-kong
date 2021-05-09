##########################
# Create a VPC
##########################
resource "aws_vpc" "kong_vpc" {
  cidr_block           = "10.10.0.0/25"
  enable_dns_hostnames = true
  enable_dns_support   = true

  #main_route_table_id - The ID of the main route table associated with this VPC. Note that you can change a VPC's main route table by using an aws_main_route_table_association.
  #default_network_acl_id - The ID of the network ACL created by default on VPC creation
  #default_security_group_id - The ID of the security group created by default on VPC creation
  #default_route_table_id 

  tags = {
    Name = "kong_vpc"
  }
}

##########################
##   IGW
##########################
resource "aws_internet_gateway" "igw_lbaas_kong" {
  vpc_id = aws_vpc.kong_vpc.id

  tags = {
    Name = "igw_lbaas_kong"
  }
}

##########################
##   Subnets Kong
##########################
resource "aws_subnet" "subnet_kong_1" {
  vpc_id            = aws_vpc.kong_vpc.id
  cidr_block        = "10.10.0.0/27"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnet_kong_1"
  }

}
resource "aws_subnet" "subnet_kong_2" {
  vpc_id            = aws_vpc.kong_vpc.id
  cidr_block        = "10.10.0.32/27"
  availability_zone = "us-west-2b"
  tags = {
    Name = "subnet_kong_2"
  }

}
####################################
##   Route table subnet Kong vm
####################################
resource "aws_route_table" "rt_kong1" {
  vpc_id = aws_vpc.kong_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_kong1.id
  }
  
  tags = {
    Name = "rt_kong1"
  }
}

resource "aws_route_table" "rt_kong2" {
  vpc_id = aws_vpc.kong_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_kong2.id
  }
  
  tags = {
    Name = "rt_kong2"
  }

}

#################################################
##  NAT GW y su EIP para las subnets de VMs Kong
#################################################

resource "aws_eip" "eip_natgw_kong1" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw_lbaas_kong]
  tags = {
    Name = "eip_natgw_kong1"
  }
}

resource "aws_eip" "eip_natgw_kong2" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw_lbaas_kong]
  tags = {
    Name = "eip_natgw_kong2"
  }
}

resource "aws_nat_gateway" "nat_gw_kong1" {
  allocation_id = aws_eip.eip_natgw_kong1.id
  subnet_id     = aws_subnet.subnet_lbaas_1.id
  depends_on = [aws_eip.eip_natgw_kong1]

  tags = {
    Name = "nat_gw_kong1"
  }
}

resource "aws_nat_gateway" "nat_gw_kong2" {
  allocation_id = aws_eip.eip_natgw_kong2.id
  subnet_id     = aws_subnet.subnet_lbaas_2.id
  depends_on = [aws_eip.eip_natgw_kong2]

  tags = {
    Name = "nat_gw_kong2"
  }
}

#############################################
##  Association Route table <-> subnet Kong
#############################################

resource "aws_route_table_association" "rt_assoc_subnets_kong1" {
  subnet_id      = aws_subnet.subnet_kong_1.id
  route_table_id = aws_route_table.rt_kong1.id
}

resource "aws_route_table_association" "rt_assoc_subnets_kong2" {
  subnet_id      = aws_subnet.subnet_kong_2.id
  route_table_id = aws_route_table.rt_kong2.id
}


##########################
##   Subnets ALB
##########################
resource "aws_subnet" "subnet_lbaas_1" {
  vpc_id            = aws_vpc.kong_vpc.id
  cidr_block        = "10.10.0.64/27"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnet_lbaas_1"
  }

}
resource "aws_subnet" "subnet_lbaas_2" {
  vpc_id            = aws_vpc.kong_vpc.id
  cidr_block        = "10.10.0.96/27"
  availability_zone = "us-west-2b"
  tags = {
    Name = "subnet_lbaas_2"
  }

}

####################################
##   Route table subnet lbbas
####################################
resource "aws_route_table" "rt_lbaas_kong" {
  vpc_id = aws_vpc.kong_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_lbaas_kong.id
  }

  tags = {
    Name = "rt_lbaas_kong"
  }

}

#############################################
##  Association Route table <-> subnet lbbas
#############################################
resource "aws_route_table_association" "rt_assoc_subnets_lbass1" {
  subnet_id      = aws_subnet.subnet_lbaas_1.id
  route_table_id = aws_route_table.rt_lbaas_kong.id
}

resource "aws_route_table_association" "rt_assoc_subnets_lbass2" {
  subnet_id      = aws_subnet.subnet_lbaas_2.id
  route_table_id = aws_route_table.rt_lbaas_kong.id
}

