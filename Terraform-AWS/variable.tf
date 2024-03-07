# Variable for CIDR Block of VPC
variable "cidr" {
  default = "10.0.0.0/16"
}

# Variable for CIDR Block of subnet1
variable "subnet1" {
  default = "10.0.0.0/24"
}

# Variable for CIDR Block of subnet2
variable "subnet2" {
  default = "10.0.1.0/24"
}

# Variable for CIDR Block of route table
variable "RT" {
  default = "0.0.0.0/0"
}
