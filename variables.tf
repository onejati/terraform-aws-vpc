#------------------------------------------#
# AWS Environment Values
#------------------------------------------#
variable "access_key" {
    description = "AWS account access key ID"
}

variable "secret_key" {
    description = "AWS account secret access key"
}

variable "region"{
decription = "EC2 Region for the VPC"
    default = "ap-south-1"
}
variable "key_name" {
    default = "rancher-example"
    description = "SSH key name in your AWS account for AWS instances."
}
variable "tag_name" {                                                  
    default     = "Mumbai"                                         
    description = "Name tag for the servers"                           
}
