// This stanza declares the default region for our provider. The other
// attributes such as access_key and secret_key will be read from the
// environment instead of committed to disk for security.
provider "aws" {
  region = "${var.aws_region}"
}

// Create a Virtual Private Network (VPC) for our tutorial. Any resources we
// launch will live inside this VPC. We will not spend much detail here, since
// these are really Amazon-specific configurations and the beauty of Terraform
// is that you only have to configure them once and forget about it!
resource "aws_vpc" "portal_infra" {
  cidr_block = "${cidrsubnet(var.aws_vpc_cidr_block, 8, var.region_number[var.aws_region])}"
  enable_dns_hostnames = true

  tags { Name = "portal_infra" }
}

// The Internet Gateway is like the public router for your VPC. It provides
// internet to-from resources inside the VPC.
resource "aws_internet_gateway" "portal_infra" {
  vpc_id = "${aws_vpc.portal_infra.id}"
  tags { Name = "portal_infra" }
}

data "aws_availability_zones" "available" {}

data "aws_availability_zone" "portal_infra" {
  count = 3
  name = "${data.aws_availability_zones.available.names[count.index]}"
}

// The subnet is the IP address range resources will occupy inside the VPC. Here
// we have choosen the 10.0.0.x subnet with a /24. You could choose any class C
// subnet.
resource "aws_subnet" "portal_infra" {
  count = 3

  vpc_id = "${aws_vpc.portal_infra.id}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block = "${cidrsubnet(aws_vpc.portal_infra.cidr_block, 8, count.index)}"

  tags { Name = "portal_infra" }

  map_public_ip_on_launch = true
}

// The Routing Table is the mapping of where traffic should go. Here we are
// telling AWS that all traffic from the local network should be forwarded to
// the Internet Gateway created above.
resource "aws_route_table" "portal_infra" {
  vpc_id = "${aws_vpc.portal_infra.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.portal_infra.id}"
  }

  tags { Name = "portal_infra" }
}

// The Route Table Association binds our subnet and route together.
resource "aws_route_table_association" "portal_infra" {

  count = 3
  subnet_id = "${element(aws_subnet.portal_infra.*.id, count.index)}"
  route_table_id = "${aws_route_table.portal_infra.id}"
}

// The AWS Security Group is akin to a firewall. It specifies the inbound
// (ingress) and outbound (egress) networking rules. This particular security
// group is intentionally insecure for the purposes of this tutorial. You should
// only open required ports in a production environment.
resource "aws_security_group" "portal_infra" {
  name   = "portal_infra-web"
  vpc_id = "${aws_vpc.portal_infra.id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
