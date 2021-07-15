#Define the provider
provider "aws" {
  region = "us-east-1"
}
#Create a vpc Region
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "name" = "my_vpc"
    "env" = "Prod"
  }
}
#Create an application Subnet
resource "aws_subnet" "my_subnet" {
   vpc_id = aws_vpc.my_vpc.id
   cidr_block = "10.0.1.0/24"
   map_public_ip_on_launch = true

}
#Create a routing table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    "name" = "Public_Route_table"
  }
}
#Create Route table Association
resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.my_route_table.id
}
resource "aws_internet_gateway" "my_IG" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    "name" = "my_IG"
  }
}
resource "aws_route" "public_route" {
    route_table_id = aws_route_table.my_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_IG.id
}
resource "aws_security_group" "app_SG" {
  name        = "app_SG"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.my_vpc.id
  ingress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  } 
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
