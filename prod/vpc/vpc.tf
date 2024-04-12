terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "../../modules/vpc"

  name = join("-",concat(tolist([var.env,"odark"])))
  cidr = var.cidr_map[var.env]

  azs = var.azs
  private_subnet = var.subnet_cidr_map.private[var.env]
  public_subnet = var.subnet_cidr_map.public[var.env]
  private_db_subnet = var.subnet_cidr_map.private_db[var.env]


  enable_dns_hostnames            = true
  enable_dns_support              = true
  enable_nat_gateway              = true
  single_nat_gateway              = false
  one_nat_gateway_per_az          = true

  tags = {
    Terraform   = "true"
    Environment = var.env
    Owner       = "odark"
    #"kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }


  public_subnet_tags = {
    "kubernetes.io/role/elb"                                                         = "1"
    #"kubernetes.io/cluster/${join("-",compact(tolist(["odark",var.env,var.vpc_name])))}" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                                = "1"
    #"kubernetes.io/cluster/${join("-",compact(tolist(["odark",var.env,var.vpc_name])))}" = "shared"
  }

}