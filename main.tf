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
    cidr_blocks = ["92.40.249.239/32"]
  }

    lifecycle {

      create_before_destroy = true
    
    }
  
}
resource "aws_lauch_configuration" "example" {

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

resource "aws_autoscaling_group" "exampl" {

  lauch_configuration = "${aws_lauch_configuration.example.id}"
  availability_zones    = ["${data.aws_availability_zones.all.names"}]

  min_size = 3
  max_size = 10

  {
    key                     = "Name"
    value                   = "terraform-asg-example"
    propagate_at_launch     = true
  }
  
}

resource "aws_elb" "example" {

  name                      = "terraform-example"
  availability_zones        = ["${data.aws_availability_zones.all.names}"]
  
}