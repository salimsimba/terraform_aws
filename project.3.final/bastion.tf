## AWS EC2 {{{1
## Instance - Bastion1 {{{2
resource "aws_instance" "Bastion1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.publicA.id

  vpc_security_group_ids = [
    aws_security_group.BastionSG.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion1" })
  )
}

## Instance - Bastion2 {{{2
resource "aws_instance" "Bastion2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.publicB.id

  vpc_security_group_ids = [
    aws_security_group.BastionSG.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion2" })
  )
}

## Instance - Bastion3 {{{2
resource "aws_instance" "Bastion3" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.publicC.id

  vpc_security_group_ids = [
    aws_security_group.BastionSG.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion3" })
  )
}
## }}}2
## }}}1

output "bastion1_ip_addr" { value = aws_instance.Bastion1.public_ip }
output "bastion2_ip_addr" { value = aws_instance.Bastion2.public_ip }
output "bastion3_ip_addr" { value = aws_instance.Bastion3.public_ip }
