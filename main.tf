resource "aws_instance" "example" {
  
  ami         = "ami-01e6a0b85de033c99"
  instance_type   = "t2.micro"

  tags = {

    Name = "terraform-example"
  }
}