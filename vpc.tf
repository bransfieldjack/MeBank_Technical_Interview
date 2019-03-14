# Configure the AWS Provider
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Define a vpc
resource "aws_vpc" "mebank-vpc" {
  cidr_block = "10.0.0.0/16" 
  tags {
    Name = "mebank-vpc"
  }
}

# Internet gateway for the public subnet
  resource "aws_internet_gateway" "mebank-ig" {
    vpc_id = "${aws_vpc.mebank-vpc.id}"
    tags {
      Name = "mebank-internet-gateway"
    }
  }
  
# Public subnet 
resource "aws_subnet" "mebank-public-subnet-1" {
  vpc_id = "${aws_vpc.mebank-vpc.id}"
  cidr_block = "10.0.101.0/24"
  availability_zone = "ap-southeast-2a"
  tags {
    Name = "public_subnet_1"
  }
}

# Private subnet 
resource "aws_subnet" "mebank-private-subnet-1" {
  vpc_id = "${aws_vpc.mebank-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-2b"
  tags {
    Name = "mebank-private-subnet-1"
  }
}

# Routing table for public subnet
  resource "aws_route_table" "mebank-public-subnet-routing-table" {
    vpc_id = "${aws_vpc.mebank-vpc.id}"
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.mebank-ig.id}"
    }
    tags {
      Name = "mebank-public-subnet-routing-table"
    }
  }

# Associate the routing table to public subnet
  resource "aws_route_table_association" "mebank-public-subnet-routing-table-association" {
    subnet_id = "${aws_subnet.mebank-public-subnet-1.id}"
    route_table_id = "${aws_route_table.mebank-public-subnet-routing-table.id}"
  }
  
# ECS Instance Security group

  resource "aws_security_group" "mebank-public-sg" {
      name = "mebank-public-sg"
      description = "Test public access security group"
      vpc_id = "${aws_vpc.mebank-vpc.id}"

     ingress {
         from_port = 22
         to_port = 22
         protocol = "tcp"
         cidr_blocks = [
            "0.0.0.0/0"]
     }

      egress {
          # allow all traffic to private SN
          from_port = "0"
          to_port = "0"
          protocol = "-1"
          cidr_blocks = [
              "0.0.0.0/0"]
      }

      tags {
         Name = "mebank-public-sg"
       }
  }
