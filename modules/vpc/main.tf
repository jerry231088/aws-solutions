resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
            Name = var.name
    })
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    var.tags,
    {
            Name = "${var.name}-igw"
    })
}

resource "aws_subnet" "public_subnet" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
            Name = "${var.name}-public-${var.azs[count.index]}"
    })
}

resource "aws_subnet" "private_subnet" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
            Name = "${var.name}-private-${var.azs[count.index]}"
    })
}

resource "aws_route_table" "public_rt_tbl" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt_tbl.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = length(var.azs)

  route_table_id = aws_route_table.public_rt_tbl.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_eip" "nat" {
  count = length(var.azs)

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-eip-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "my_natgw" {
  count = length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  depends_on    = [aws_internet_gateway.my_igw]

  tags = merge(
      var.tags,
      {
        Name = "${var.name}-nat-${var.availability_zones[count.index]}"
      }
    )
}

resource "aws_route_table" "private_rt_tbl" {
  count = length(var.azs)

  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-rt-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_route" "private_nat" {
  count = length(var.azs)

  route_table_id         = aws_route_table.private_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_natgw[count.index].id
}

resource "aws_route_table_association" "private_rt_assoc" {
  count = length(var.azs)

  route_table_id = aws_route_table.private_rt_tbl[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
