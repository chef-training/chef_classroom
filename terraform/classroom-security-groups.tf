resource "aws_security_group" "portal" {
    name        = "training-tsukumen-portal"
    description = "training-tsukumen-portal"
    vpc_id      = "${aws_vpc.classroom.id}"

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        "Name" = "training-tsukumen-portal"
    }
}

resource "aws_security_group" "nodes" {
    name        = "training-tsukumen-nodes"
    description = "training-tsukumen-nodes"
    vpc_id      = "${aws_vpc.classroom.id}"

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32", "0.0.0.0/0"]
        security_groups = ["${aws_security_group.workstations.id}"]
        self            = false
    }

    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32", "0.0.0.0/0"]
        security_groups = ["${aws_security_group.workstations.id}"]
        self            = false
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32", "0.0.0.0/0"]
        security_groups = ["${aws_security_group.workstations.id}"]
        self            = false
    }

    ingress {
        from_port       = 5986
        to_port         = 5986
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32", "0.0.0.0/0"]
        security_groups = ["${aws_security_group.workstations.id}"]
        self            = false
    }

    ingress {
        from_port       = 3389
        to_port         = 3389
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32", "0.0.0.0/0"]
    }

    ingress {
        from_port       = 5985
        to_port         = 5985
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32", "0.0.0.0/0"]
        security_groups = ["${aws_security_group.workstations.id}"]
        self            = false
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        "Name" = "training-tsukumen-nodes"
    }
}

resource "aws_security_group" "workstations" {
    name        = "training-tsukumen-workstations"
    description = "training-tsukumen-workstations"
    vpc_id      = "${aws_vpc.classroom.id}"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0", "172.31.1.167/32"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        "Name" = "training-tsukumen-workstations"
    }
}

resource "aws_security_group" "chef-server" {
    name        = "training-tsukumen-chef_server"
    description = "training-tsukumen-chef_server"
    vpc_id      = "${aws_vpc.classroom.id}"

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["172.31.1.167/32"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = ["sg-0b536a6e"]
        self            = false
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        "Name" = "chef-server"
    }
}
