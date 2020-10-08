
variable "ACCESS_KEY" {
default = "***********"
}

variable "SECRET_KEY" {
default = "************"
}

variable "region" {
default = "eu-central-1"
}



variable "cidr_blocks_ingress" { 

default = ["151.56.0.0/16"]
}

variable "cidr_blocks_egress" { 

default = ["0.0.0.0/0"]
}


variable "vpc_cidr" {

default = "172.31.0.0/16"
}

variable "subnet_cidr" {

default = "172.31.0.0/20"
}
############################
# Emr variables
############################

variable "applications" {

default = ["Spark"]
}

variable "log_uri" {

default = "s3://bankdataset1"
}

variable "release_label" {
  default = "emr-5.30.0"
}
variable "instance_type" {
  default = "m5.xlarge"
}

variable "instance_count" {
  default = 2
}

variable "size" {
  default = 40 
}




