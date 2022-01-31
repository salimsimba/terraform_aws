## AWS EC2 {{{1
## Instance App1 {{{2
resource "aws_instance" "App1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.AppA.id

  vpc_security_group_ids = [
    aws_security_group.AppSG.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-app1" })
  )
}

## Instance App2 {{{2
resource "aws_instance" "App2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.AppB.id

  vpc_security_group_ids = [
    aws_security_group.AppSG.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-app2" })
  )
}

## Instance App3 {{{2
resource "aws_instance" "App3" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.AppC.id

  vpc_security_group_ids = [
    aws_security_group.AppSG.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-app3" })
  )
}
## }}}2
## }}}1

output "app1_ip_addr" { value = aws_instance.App1.private_ip }
output "app2_ip_addr" { value = aws_instance.App2.private_ip }
output "app3_ip_addr" { value = aws_instance.App3.private_ip }
