variable "cidr" {
 default = "10.0.0.0/16"  
}

variable "region" {
    default = "ap-south-1"
}

variable "sg1_az" {
  default = "ap-south-1a"
}

variable "sg2_az"{
    default = "ap-south-1b"
}
variable "sg1_cidR" {
  default = "10.0.0.0/24"
}
variable "sg2_cidR" {
  default = "10.0.1.0/24"
}