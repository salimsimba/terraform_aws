## VPC {{{1
resource "aws_vpc" "main" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )
}

## Internet Gateway {{{2
resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}
## }}}2

## Public Subnets {{{2
## Route - MyPublicRoute {{{3
resource "aws_route_table" "MyPublicRoute" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_route_table_association" "publicA" {
  subnet_id      = aws_subnet.publicA.id
  route_table_id = aws_route_table.MyPublicRoute.id
}

resource "aws_route_table_association" "publicB" {
  subnet_id      = aws_subnet.publicB.id
  route_table_id = aws_route_table.MyPublicRoute.id
}

resource "aws_route_table_association" "publicC" {
  subnet_id      = aws_subnet.publicC.id
  route_table_id = aws_route_table.MyPublicRoute.id
}

## Inbound/Outbound Internet Access
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.MyPublicRoute.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.MyIGW.id
}

## Subnet - publicA {{{3
resource "aws_subnet" "publicA" {
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a" })
  )
}

resource "aws_eip" "publicA" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a" })
  )
}

resource "aws_nat_gateway" "publicA" {
  allocation_id = aws_eip.publicA.id
  subnet_id     = aws_subnet.publicA.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a" })
  )
}

## Subnet - publicB {{{3
resource "aws_subnet" "publicB" {
  cidr_block              = "172.16.2.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b" })
  )
}

resource "aws_eip" "publicB" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b" })
  )
}

resource "aws_nat_gateway" "publicB" {
  allocation_id = aws_eip.publicB.id
  subnet_id     = aws_subnet.publicB.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b" })
  )
}

## Subnet - publicC {{{3
resource "aws_subnet" "publicC" {
  cidr_block              = "172.16.3.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}c"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-c" })
  )
}

resource "aws_eip" "publicC" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-c" })
  )
}

resource "aws_nat_gateway" "publicC" {
  allocation_id = aws_eip.publicC.id
  subnet_id     = aws_subnet.publicC.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-c" })
  )
}
## }}}2

## Private SubNets {{{2
## PrivateA {{{3
## Route - MyPrivateRouteA {{{4
resource "aws_route_table" "MyPrivateRouteA" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-a" })
  )
}

resource "aws_route_table_association" "AppA" {
  subnet_id      = aws_subnet.AppA.id
  route_table_id = aws_route_table.MyPrivateRouteA.id
}

resource "aws_route_table_association" "DbA" {
  subnet_id      = aws_subnet.DbA.id
  route_table_id = aws_route_table.MyPrivateRouteA.id
}

# Outbound Internet Access
resource "aws_route" "private_a_internet_out" {
  route_table_id         = aws_route_table.MyPrivateRouteA.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.publicA.id
}

## Subnet - AppA {{{4
resource "aws_subnet" "AppA" {
  cidr_block        = "172.16.4.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-a" })
  )
}

## Subnet - DbA {{{4
resource "aws_subnet" "DbA" {
  cidr_block        = "172.16.8.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-a" })
  )
}
## }}}4

## PrivateB {{{3
## Route - MyPrivateRouteB {{{4
resource "aws_route_table" "MyPrivateRouteB" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-b" })
  )
}

resource "aws_route_table_association" "AppB" {
  subnet_id      = aws_subnet.AppB.id
  route_table_id = aws_route_table.MyPrivateRouteB.id
}

resource "aws_route_table_association" "DbB" {
  subnet_id      = aws_subnet.DbB.id
  route_table_id = aws_route_table.MyPrivateRouteB.id
}

# Outbound Internet Access
resource "aws_route" "private_b_internet_out" {
  route_table_id         = aws_route_table.MyPrivateRouteB.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.publicB.id
}

## Subnet - AppB {{{4
resource "aws_subnet" "AppB" {
  cidr_block        = "172.16.5.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-b" })
  )
}

## Subnet - DbB {{{4
resource "aws_subnet" "DbB" {
  cidr_block        = "172.16.9.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-b" })
  )
}
## }}}4

## PrivateC {{{3
## Route - MyPrivateRouteC {{{4
resource "aws_route_table" "MyPrivateRouteC" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-c" })
  )
}

resource "aws_route_table_association" "AppC" {
  subnet_id      = aws_subnet.AppC.id
  route_table_id = aws_route_table.MyPrivateRouteC.id
}

resource "aws_route_table_association" "DbC" {
  subnet_id      = aws_subnet.DbC.id
  route_table_id = aws_route_table.MyPrivateRouteC.id
}

# Outbound Internet Access
resource "aws_route" "private_c_internet_out" {
  route_table_id         = aws_route_table.MyPrivateRouteC.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.publicC.id
}

## Subnet - AppC {{{4
resource "aws_subnet" "AppC" {
  cidr_block        = "172.16.6.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}c"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-c" })
  )
}

## Subnet - DbC {{{4
resource "aws_subnet" "DbC" {
  cidr_block        = "172.16.10.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}c"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-c" })
  )
}
## }}}4
## }}}3
## }}}2
## }}}1
