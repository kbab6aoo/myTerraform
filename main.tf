data "template_file" "user_data" {

  template        = "${file("user-data.sh")}"

  vars = {

    server_port   = "${var.server_port}"
    db_address    = "${data.terraform_remote_state.db.address}"
    db_port       = "${data.terraform_remote_state.db.port}"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {

    bucket      = "jcs-eu-west-1-teraform-up-and-running-remote-state"
    key         = "env-Demo/data-storage/mysql/terraform.tfstate"
    region      = "eu-west-1"
    profile     = "dev-jcs"

  }
}

resource "aws_instance" "example" {
  
  ami         = "ami-01e6a0b85de033c99"
  instance_type   = "t2.micro"

  vpc_security_group_ids  = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
                #!/bin/bash
                echo "Welcome to Jagho Cloud Services!.." > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

  tags = {

    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terrafrom-example-instance"

  ingress {

    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["188.29.165.237/32"]
  }

    # lifecycle {

    #   create_before_destroy = true
    
    # }
  
}
resource "aws_launch_configuration" "example" {

  image_id          = "ami-01e6a0b85de033c99"
  instance_type     = "t2.micro"

  security_groups   = ["${aws_security_group.instance.id}"]

    user_data = <<-EOF
                #!/bin/bash
                echo "Welcome to Jagho Cloud Services!.." > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

    lifecycle {

      create_before_destroy = true

    }
  
}
data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example" {

  launch_configuration    = "${aws_launch_configuration.example.id}"
  availability_zones      = "${data.aws_availability_zones.all.names}"

  load_balancers           = ["${aws_elb.example.name}"]
  health_check_type       = "ELB"

      min_size = 3
      max_size = 10

  tag {

    key                     = "Name"
    value                   = "terraform-asg-example"
    propagate_at_launch     = true
    
    }
  
}

resource "aws_elb" "example" {

  name                      = "terraform-asg-example"
  availability_zones        = "${data.aws_availability_zones.all.names}"
  security_groups           = ["${aws_security_group.alb.id}"]
  
  listener {

    lb_port                 = 80
    lb_protocol             = "http"
    instance_port           = "${var.server_port}"
    instance_protocol       = "http"
  }
  health_check {

    healthy_threshold       = 2
    unhealthy_threshold     = 2
    timeout                 = 3
    interval                = 30
    target                  = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "alb" {

  name                      = "terraform-example-alb"

  ingress {

    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  egress {

    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  
}