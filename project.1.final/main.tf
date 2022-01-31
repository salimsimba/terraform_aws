provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "hello_world" {
  ami = "ami-01ca03df4a6012157"
  instance_type = "t2.micro"
  key_name = "myec2key"

  tags = {
    Name = "HelloWorld"
  }
}
