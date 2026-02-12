# Associate EIP address to an instance.

resource "aws_eip" "lb" {
  domain   = "vpc"

  tags = {
    Name = "test_EIP"
  }
}