variable "cidr_map" {
    default = {
         prod = "10.1.0.0/16",
         dev = "10.1.0.0/16"
    }
    type = map
}

variable "cluster_name" {
    default = "kuber-demo"
    type = string
} 

variable "tenancy" {
    default = "default"
    type = string
}

variable "enable_dns_hostnames" {
    default = true
    type = bool
}

variable "enable_dns_support" {
    default = true
    type = bool
}

variable "vpc_name" {
    default = "k8s-demo"
    type = string
}

variable "additional_cidr" {
    default = ["192.168.0.0/24"]
    type = list(string)
}

variable "azs" {
    default = ["ap-northeast-2a", "ap-northeast-2c"]
    type = list(string)
}

variable "env" {
    default = "prod"
    type = string
}



# variable "private_db_subnet_prefix" {
#     default = "prod-db"
#     type = string
# }

# variable "single_nat_gateway" {
#     default = false
#     type = bool
# }

# variable "one_nat_gateway_per_az" {
#     default = false
#     type = bool
# }

# variable "enable_nat_gateway" {
#     default = false
#     type = bool
# }

variable "subnet_cidr_map" {
 type = map
    default = {
        public= {
            prod=["10.1.1.0/26", "10.1.1.64/26"],
            dev=["10.1.1.0/26", "10.1.1.64/26"]
        },
        private= {
            prod=["10.1.1.128/27", "10.1.1.160/27"],
            dev=["10.1.1.128/27", "10.1.1.160/27"]
        },
        private_db= {
            prod=["10.1.1.192/27", "10.1.1.224/27"],
            dev=["10.1.1.192/27", "10.1.1.224/27"]
        }

    }
}

#terraform cloud에서 terrraform variables 타입변수를 위해 선언해줘야 한다.
variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key Id"
  type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type    = string
}