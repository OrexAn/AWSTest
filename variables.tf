variable "vpc_cidr" {
  description = "Value of the CIDR range for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Value of the name for the VPC"
  type = string
  default = "MyTestVPC"
}

variable "subnet_cidr" {
  description = "Value of the subnet cidr for the VPC"
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR Block for Private Subnet"
  default     = "10.0.3.0/24"
}

variable "public_subnet_name" {
  description = "Value of the public subnet name for the VPC"
  type = string
  default = "MyTestPublicSubnet"
}

variable "private_subnet_name" {
  description = "Value of the private subnet name for the VPC"
  type = string
  default = "MyTestPrivateSubnet"
}

variable "ubuntu_instance_name" {
  description = "Value of the Name tag for the EC2 ubuntu instance"
  type = string
  default = "UbuntuEC2"
}

variable "public_igw_name" {
  description = "Value of the public Internet Gateway name for the VPC"
  type = string
  default = "MyTestPublicIGW"
}

variable "linux_instance_name" {
  description = "Value of the Name tag for the EC2 linux instance"
  type = string
  default = "LinuxEC2"
}

variable "ubuntu_instance_type" {
  description = "Ubuntu EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "linux_instance_type" {
  description = "Linux EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}