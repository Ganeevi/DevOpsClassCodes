provider "aws" {
        region = "ap-south-1"
}

resource "aws_vpc" "myVPC" {
        tags = { Name = "myVPC" }
        cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "myIGW" {
        tags = { Name = "myIGW" }
        vpc_id = aws_vpc.myVPC.id
}

resource "aws_subnet" "Public_Subnet-1a" {
        tags = { Name = "Public_Subnet-1a" }
        cidr_block = "10.0.1.0/24"
        vpc_id = aws_vpc.myVPC.id
        availability_zone = "ap-south-1a"
}

resource "aws_subnet" "Public_Subnet-1b" {
        tags = { Name = "Public_Subnet-1b" }
        cidr_block = "10.0.2.0/24"
        vpc_id = aws_vpc.myVPC.id
        availability_zone = "ap-south-1b"
}

resource "aws_route_table" "Public_RT" {
        tags = { Name = "Public_RT" }
        vpc_id = aws_vpc.myVPC.id
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = aws_internet_gateway.myIGW.id
        }
}

resource "aws_route_table_association" "Public-RT-Asso-1a" {
        subnet_id = aws_subnet.Public_Subnet-1a.id
        route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "Public-RT-Asso-1b" {
        subnet_id = aws_subnet.Public_Subnet-1b.id
        route_table_id = aws_route_table.Public_RT.id
}

resource "aws_security_group" "Web_SG" {
        vpc_id = aws_vpc.myVPC.id
        tags = { Name = "Web_SG" }
        ingress {
                from_port = 8080
                to_port = 8080
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = 8081
                to_port = 8081
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = 8082
                to_port = 8082
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = 0
                to_port = 0
                protocol = -1
                cidr_blocks = ["0.0.0.0/0"]
        }
}

resource "aws_instance" "Jenkins-Master" {
        ami = "ami-0451f2687182e0411"
        instance_type = "t2.micro"
        key_name = "Mumbai"
        subnet_id = "${aws_subnet.Public_Subnet-1a.id}"
        vpc_security_group_ids = [ aws_security_group.Web_SG.id ]
        associate_public_ip_address = "true"
        tags = { Name = "Jenkins-Master" }
        user_data = "${file("package.sh")}"
        user_data_replace_on_change = "true"
}

resource "aws_instance" "Jenkins-Slave" {
        ami = "ami-0451f2687182e0411"
        instance_type = "t2.micro"
        key_name = "Mumbai"
        count = 2
        subnet_id = "${aws_subnet.Public_Subnet-1b.id}"
        vpc_security_group_ids = [ aws_security_group.Web_SG.id ]
        associate_public_ip_address = "true"
        tags = { Name = "Jenkins-Slave" }
        user_data = "${file("slave_package.sh")}"
        user_data_replace_on_change = "true"
}

resource "aws_instance" "jfrog-artifactory" {
        ami = "ami-0a1b648e2cd533174"
        instance_type = "t2.medium"
        key_name = "Mumbai"
        count = 1
        subnet_id = "${aws_subnet.Public_Subnet-1a.id}"
        vpc_security_group_ids = [ aws_security_group.Web_SG.id ]
        associate_public_ip_address = "true"
        tags = { Name = "jfrog-artifactory" }
        user_data = "${file("jfrog.sh")}"
        user_data_replace_on_change = "true"
}
