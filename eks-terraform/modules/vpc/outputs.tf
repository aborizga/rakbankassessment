output "aws_public_subnet" {
  value = aws_subnet.public_rakbank_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.rakbank_vpc.id
}
