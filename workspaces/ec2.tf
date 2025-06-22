resource "aws_instance" "roboshop" {
  count                  = length(var.instances)
  ami                    = var.ami_id # left and right side names no need to be same
  instance_type          = lookup(var.instance_type, terraform.workspace)
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.instances[count.index]}-${terraform.workspace}"
      Component = var.instances[count.index]
      Environment = terraform.workspace
    }
  )
}
# ALLOW ALL SG
resource "aws_security_group" "allow_all" {
  name        = "${var.project}-${var.sg_name}-${terraform.workspace}" # allow-all-dev
  description = var.sg_description

  ingress {
    from_port        = var.from_port
    to_port          = var.to_port
    protocol         = "-1"
    cidr_blocks      = var.cidr_blocks
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = var.from_port
    to_port          = var.to_port
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.sg_name}-${terraform.workspace}"
    }
  )
}