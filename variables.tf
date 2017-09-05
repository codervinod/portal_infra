// This stanza declares the provider we are declaring the AWS region we want
// to use. We declare this as a variable so we can access it other places in
// our Terraform configuration since many resources in AWS are region-specific.
variable "aws_region" {
  default = "us-east-1"
}

// This stanza declares a variable named "ami_map" that is a mapping of the
// Ubuntu 14.04 official hvm:ebs volumes to their region. This is used to
// demonstrate the power of multi-provider Terraform and also allows this
// tutorial to be adjusted geographically easily.
variable "aws_amis" {
  default = {
    us-east-1      = "ami-0c2c481a"
    us-west-1      = "ami-28b4e848"
  }
}

variable "aws_vpc_cidr_block" {
  default = "10.0.0.0/8"
}

variable "aws_instance_type" {
  default = "c3.2xlarge"
}
variable "region_number" {
  # Arbitrary mapping of region name to number to use in
  # a VPC's CIDR prefix.
  default = {
    us-east-1      = 1
    us-west-1      = 2
    us-west-2      = 3
    eu-central-1   = 4
    ap-northeast-1 = 5
  }
}

variable "az_number" {
  # Assign a number to each AZ letter used in our configuration
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }
}

