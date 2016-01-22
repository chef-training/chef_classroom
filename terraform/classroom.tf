variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "us-west-1"
}
variable "az" {
    default = "us-west-1a"
}
variable "class" {
    default = "venture-industries"
}
variable "key_name" {
    default = "USER_REGION"
}
variable "ttl" {
    default = 8
}

variable "amis" {
    default = {
        amzn = "ami-d114f295"
        centos = "ami-57cfc412"
        chef_server = "ami-9ea6cefe"
    }
}
variable "type" {
    default = {
        chef_server = "m3.medium"
        node_amzn = "t2.micro"
        portal = "m3.medium"
        workstation = "t2.medium"
    }
}


provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_iam_instance_profile" "classroom" {
    name  = "classroom"
    path  = "/"
    roles = ["classroom"]
}

resource "aws_iam_role" "classroom" {
    name               = "classroom"
    path               = "/"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_vpc" "classroom" {
    cidr_block           = "172.31.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
      "Class" = "${var.class}"
      "TTL" = "${var.ttl}"
      "Name" = "classroom VPC"
    }
}

resource "aws_subnet" "classroom" {
    vpc_id                  = "${aws_vpc.classroom.id}"
    cidr_block              = "172.31.0.0/20"
    availability_zone       = "us-west-1a"
    map_public_ip_on_launch = true

    tags {
      "Class" = "${var.class}"
      "TTL" = "${var.ttl}"
      "Name" = "classroom subnet"
    }
}

resource "aws_instance" "portal" {
    ami                         = "${var.amis.centos}"
    availability_zone           = "${var.az}"
    instance_type               = "${var.type.portal}"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${aws_subnet.classroom.id}"
    vpc_security_group_ids      = ["${aws_security_group.portal.id}"]
    associate_public_ip_address = true
    /*private_ip                  = "172.31.33.171"*/
    source_dest_check           = true

    tags {
        "Class" = "${var.class}"
        "Name" = "portal"
        "TTL" = "${var.ttl}"
    }
}

resource "aws_instance" "chef-server" {
    ami                         = "${var.amis.chef_server}"
    availability_zone           = "${var.az}"
    instance_type               = "${var.type.chef_server}"
    key_name                    = "${var.key_name}"
    subnet_id                    = "${aws_subnet.classroom.id}"
    vpc_security_group_ids      = ["${aws_security_group.chef-server.id}"]
    associate_public_ip_address = true
    /*private_ip                  = "172.31.54.57"*/

    tags {
        "Class" = "${var.class}"
        "Name" = "classroom chef server"
        "TTL" = "${var.ttl}"
    }

    provisioner "remote-exec" {
        inline = [
        "chef-marketplace-ctl setup -y --username 'instructor' --password 'password' --firstname 'Bill' --lastname 'Brasky' --email 'training-chef@chef.io' --org 'chef-training'"
        ]
    }
}
