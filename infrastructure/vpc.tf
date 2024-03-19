module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name                 = "vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["eu-west-1a", "eu-west-1b"]
  private_subnets      = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.0.0/24", "10.0.2.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
}
