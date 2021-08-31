resource "aws_vpc" "default" {
  cidr_block = "10.32.0.0/16"
  tags = {
    Name = "travel-mate-vpc-${var.env_name}"
  }
}

resource "aws_subnet" "public" {
  count             = var.availability_count
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, var.availability_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.default.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = var.availability_count
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.default.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id            = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id    = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id        = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count             = var.availability_count
  vpc               = true
  depends_on        = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count             = var.availability_count
  subnet_id         = element(aws_subnet.public.*.id, count.index)
  allocation_id     = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count             = var.availability_count
  vpc_id            = aws_vpc.default.id
}

resource "aws_route" "via_nat" {
  count             = var.availability_count
  route_table_id    = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id    = element(aws_nat_gateway.gateway.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  count             = var.availability_count
  subnet_id         = element(aws_subnet.private.*.id, count.index)
  route_table_id    = element(aws_route_table.private.*.id, count.index)
}
  
