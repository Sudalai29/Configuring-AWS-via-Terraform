provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sg1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.sg1_cidR
  availability_zone = var.sg1_az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sg2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.sg2_cidR
  availability_zone = var.sg2_az
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igate" {
   vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igate.id
  }
}

  resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.sg1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.sg2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "secg" {
  vpc_id      = aws_vpc.vpc.id

ingress {
     description       = "HTTP from VPC" 
     cidr_blocks       = ["0.0.0.0/0"]
     from_port         = 80
     protocol          = "tcp"
     to_port           = 80
}
 ingress{
    description       = "SSH"
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 22
    protocol          = "tcp"
    to_port           = 22
 }

egress{
     cidr_blocks       = ["0.0.0.0/0"]
     from_port         = 0
     protocol          = "-1"
     to_port           = 0
 }
}
resource "aws_s3_bucket" "name" {
  bucket = "aws-infra-via-tfm"  
}

resource "aws_instance" "serverone" {
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.secg.id]
  subnet_id = aws_subnet.sg1.id
  user_data = base64encode(file("userdataA.sh"))
}

resource "aws_instance" "servertwo" {
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.secg.id ]
  subnet_id = aws_subnet.sg2.id
  user_data = base64encode(file("userdataB.sh"))
}

#create alb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.secg.id]
  subnets         = [aws_subnet.sg1.id, aws_subnet.sg2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.serverone.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.servertwo.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}