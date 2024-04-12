######
# VPC
######
resource "aws_vpc" "this" {
	cidr_block           = var.cidr                 #"10.0.0.0/16"
	instance_tenancy     = var.tenancy              #"default"
	enable_dns_hostnames = var.enable_dns_hostnames #true
	enable_dns_support   = var.enable_dns_support   #true

	tags = merge (
		{ 
			name = format("%s-vpc", var.name)
		},
		var.tags,
		var.vpc_tags
	)
}

#하나의 VPC에 대한 여러 개의 CIDR 블록을 사용할 수 있도록 하여 더 많은 서브넷 생성과 네트워크를 구성할 수 있다.
# resource "aws_vpc_ipv4_cidr_block_association" "additional_cidr" {
#     count = length(var.additional_cidr) > 0 ? length(var.additional_cidr) : 0
# 	vpc_id        = aws_vpc.this.id
# 	cidr_block    = element(var.additional_cidr, count.index)
# }

###################
# public subnet a,c 
###################
resource "aws_subnet" "public-subnet" {
 count                   = length(var.public_subnet)
   vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.public_subnet,[""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}",element(var.azs,count.index))) > 0 ? element(var.azs,count.index) : null

  map_public_ip_on_launch = true 

  tags = merge(
		{
    	"Name" = format(
							"%s-${var.public_subnet_prefix}-%s",
							var.name,
							element(var.azs,count.index)
							)
		},
		var.tags,
		var.public_subnet_tags

	)
}
####################
# private subnet a,c 
####################
resource "aws_subnet" "private-subnet" {
	count                   = length(var.private_subnet)
      vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.private_subnet,[""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}",element(var.azs,count.index))) > 0 ? element(var.azs,count.index) : null

  map_public_ip_on_launch = true

  tags = merge(
		{
    	"Name" = format(
							"%s-${var.private_subnet_prefix}-%s",
							var.name,
							element(var.azs,count.index)
							)
		},
		var.tags,
		var.private_subnet_tags
	)
}
#######################
# private db subnet a,c 
#######################
resource "aws_subnet" "private-db-subnet" {
  count                   = length(var.private_db_subnet)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.private_db_subnet,[""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}",element(var.azs,count.index))) > 0 ? element(var.azs,count.index) : null

  map_public_ip_on_launch = true

  tags = merge(
		{
    	"Name" = format(
							"%s-${var.private_db_subnet_prefix}-%s",
							var.name,
							element(var.azs,count.index)
							)
		},
		var.tags,
		var.vpc_tags
	)
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
	count = length(var.public_subnet) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  # tags = {
  #   Name = "k8s-demo-gw"
  # }
  tags = merge(
			{
				Name = format(
					"%s-gateway",
					var.name
				)
			}
	)
}

#############
# Nat Gateway
#############
locals {
	nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : length(var.private_subnet)
}

resource "aws_eip" "this" {
	count = var.enable_nat_gateway ? local.nat_gateway_count : 0
  domain  = "vpc"
	tags = merge(
		{
    	"Name" = format(
								"%s-%s",
								var.name,
								element(var.azs, var.single_nat_gateway ? 0 : count.index)
							)
  	},
		var.tags,
		var.nat_eip_tags
	)
}

resource "aws_nat_gateway" "this" {
	count = var.enable_nat_gateway ? local.nat_gateway_count : 0
  allocation_id = element(
		 								aws_eip.this.*.id, 
										var.single_nat_gateway ? 0 : count.index)
  subnet_id     = element(
										aws_subnet.public-subnet.*.id,
										var.single_nat_gateway ? 0 : count.index)

  tags = merge(
		{
    	"Name" = format(
							"%s-nat-gateway",
							var.name
						)
  	},
		var.tags,
		var.vpc_tags
	)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.this]
}

############################
# public route table for igw
############################
resource "aws_route_table" "public-route" {
  #count = length(var.public_subnet) > 0 ? 1 : 0
  count= length(aws_internet_gateway.this.*.id) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.this[count.index].id
	}
}

# public subnet associate to public route table
resource "aws_route_table_association" "public-subnet-association" {
	count = length(var.public_subnet)
  subnet_id      = element(concat(aws_subnet.public-subnet.*.id,[""]),count.index)
  route_table_id = aws_route_table.public-route[0].id
}

#####################################
# private route table for nat gateway
#####################################
resource "aws_route_table" "private-route" {
    count = var.enable_nat_gateway ? local.nat_gateway_count : 0    

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_nat_gateway.this[count.index].id
	}
}

# private subnet associate to private route table
resource "aws_route_table_association" "private-subnet-association" {
	count = length(var.private_subnet)
  subnet_id      = element(concat(aws_subnet.private-subnet.*.id,[""]),count.index)
  route_table_id = aws_route_table.private-route[count.index].id
}

#######################
# Private Network ACLs
#######################
resource "aws_network_acl" "private" {
  count = length(var.private_subnet) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.private-subnet.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}", var.name)
    },
    var.tags,
    var.private_acl_tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_subnet) > 0 ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_subnet) > 0 ? length(var.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}