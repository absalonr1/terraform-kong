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
    Name = "kong_vpc_demo"
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
resource "aws_subnet" "subnet_kong" {
  for_each = var.subnets
  vpc_id            = aws_vpc.kong_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = var.availability_zones[var.region].zones[index(keys(var.subnets), each.key)]  #each.value.az
  tags = {
    Name = "subnet_kong_${each.key}"
  }

}


#################################################
##  NAT GW y su EIP para las subnets de VMs Kong
#################################################

resource "aws_eip" "eip_natgw_kong" {
  count = length(aws_subnet.subnet_kong) 
  vpc      = true
  depends_on = [aws_internet_gateway.igw_lbaas_kong]
  tags = {
    Name = "eip_natgw_kong${count.index}"
  }
}

# https://aws.amazon.com/premiumsupport/knowledge-center/ec2-internet-connectivity/
resource "aws_nat_gateway" "nat_gw_kong" {
  count = length(aws_eip.eip_natgw_kong)
  allocation_id = aws_eip.eip_natgw_kong[count.index].id
  subnet_id     = aws_subnet.subnet_lbaas[count.index].id
  depends_on = [aws_eip.eip_natgw_kong]

  tags = {
    Name = "nat_gw_kong${count.index}"
  }
}

####################################
##   Route table subnet Kong vm
####################################
resource "aws_route_table" "rt_kong" {
  count = length(aws_nat_gateway.nat_gw_kong)
  vpc_id = aws_vpc.kong_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_kong[count.index].id
  }
  
  tags = {
    Name = "rt_kong${count.index}"
  }
}

#############################################
##  Association Route table <-> subnet Kong
#############################################

resource "aws_route_table_association" "rt_assoc_subnets_kong" {
  count = length(aws_subnet.subnet_kong)
  subnet_id      = aws_subnet.subnet_kong[count.index].id
  route_table_id = aws_route_table.rt_kong[count.index].id
}


##############################################################################
##                       Subnets ALB
##############################################################################
resource "aws_subnet" "subnet_lbaas" {
  for_each = var.subnets_lbaas
  vpc_id            = aws_vpc.kong_vpc.id
  cidr_block        = each.value.cidr
  availability_zone =  var.availability_zones[var.region].zones[index(keys(var.subnets_lbaas), each.key)] #each.value.az
  tags = {
    Name = "subnet_lbaas_${each.key}"
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
resource "aws_route_table_association" "rt_assoc_subnets_lbass" {
  count = length(aws_subnet.subnet_lbaas)
  subnet_id      = aws_subnet.subnet_lbaas[count.index].id
  route_table_id = aws_route_table.rt_lbaas_kong.id
}
