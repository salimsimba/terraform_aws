## AWS Security Group {{{1
## Security Group - AlbSG {{{2
resource "aws_security_group" "AlbSG" {
  description = "Control Application Load Balancer inbound and outbound access"
  name        = "${local.prefix}-alb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = var.app_container_port
    to_port     = var.app_container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

## Security Group - AppSG {{{2
resource "aws_security_group" "AppSG" {
  description = "Control Application inbound and outbound access"
  name        = "${local.prefix}-app-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.AlbSG.id, aws_security_group.BastionSG.id]
  }

  ingress {
    protocol    = "tcp"
    from_port   = var.app_container_port
    to_port     = var.app_container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

## Security Group - BastionSG {{{2
resource "aws_security_group" "BastionSG" {
  description = "Control Bastion inbound and outbound access"
  name        = "${local.prefix}-bastion-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
## }}}2
## }}}1
