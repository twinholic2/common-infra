variable "name" {
  default = ""
  type = string
}

variable "vpc_name" {
  default = "default"
  type    = string
}

variable "cluster_name" {
    default = ""
    type = string
} 

variable "tenancy" {
    default = "default"
    type    = string
}

variable "enable_dns_hostnames" {
  default = true
  type    = bool
}

variable "enable_dns_support" {
  default = true
  type    = bool
}

variable "additional_cidr" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  default = []
  type = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {}
  type = map(string)
}

variable "vpc_tags" {
  description = "additional tags for the VPC"
  default = {}
  type = map(string)
}

variable "cidr" {
  default = ""
  type = string
  
}

variable "azs" {
  description = "A list of availabilities zone names or ids in the region"
  default = []
  type = list(string)
}

variable "public_subnet" {
  description = "A list of public subnet inside VPC"
  default = []
  type = list(string)
}

variable "private_subnet" {
  description = "A list of private subnet inside VPC"
  default = []
  type = list(string)
}

variable "private_db_subnet" {
  description = "A list of private db subnet inside VPC"
  default = []
  type = list(string)
}

variable "public_subnet_prefix" {
  default = "public"
  type = string
} 

variable "private_subnet_prefix" {
  default = "private"
  type = string
}

variable "private_db_subnet_prefix" {
  default = "private_db"
  type = string
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "single_nat_gateway" {
  default = false
  type = bool
}

variable "one_nat_gateway_per_az" {
  default = false
  type = bool
}

variable "enable_nat_gateway" {
  default = false
  type = bool
}

variable "nat_eip_tags" {
  default = {}
  type = map(string)
}

variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "private_acl_tags" {
  description = "Additional tags for the private subnets network ACL"
  type        = map(string)
  default     = {}
}