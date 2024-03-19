# This file is excluded from the exercise - we'll use local backend only
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}