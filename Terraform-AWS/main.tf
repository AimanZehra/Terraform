# VPC
resource "aws_vpc" "VPC" {
  cidr_block = var.cidr
}

# Creating 2 Subnets with VPC:
# Subnet 1
resource "aws_subnet" "Subnet1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.subnet1
  availability_zone       = "eu-central-1"
  map_public_ip_on_launch = true
}

# Subnet 2
resource "aws_subnet" "Subnet2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.subnet2
  availability_zone       = "eu-west-1"
  map_public_ip_on_launch = true
}

# Creating Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
}

# Creating route table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = var.RT
    gateway_id = aws_internet_gateway.IGW.id
  }
}

# Attaching both Subnets to the Route table
resource "aws_route_table_association" "SN1" {
  subnet_id      = aws_subnet.Subnet1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "SN2" {
  subnet_id      = aws_subnet.Subnet2.id
  route_table_id = aws_route_table.RT.id
}

# Creating a security group for EC2
resource "aws_security_group" "mySG" {
  name        = "webSG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    protocol    = "tcp"
    description = "Http from VPC"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "SSH"
    description = "TLS from VPC"
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

  tags = {
    name = "websg"
  }
}

# Creating an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "AimanBucket"
}

# Creating EC2 Instances inside the subnets

resource "aws_instance" "webserver1" {
  ami                    = "ami-06dd92ecc74fdfb36"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mySG.id]
  subnet_id              = aws_subnet.Subnet1.id
  user_data              = base64encode(file("userdata.sh"))
}


resource "aws_instance" "webserver2" {
  ami                    = "ami-06dd92ecc74fdfb36"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mySG.id]
  subnet_id              = aws_subnet.Subnet2.id
  user_data              = base64encode(file("userdata1.sh"))
}

# Creating an Application Load Balancer (ALB)
resource "aws_lb" "testLB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySG.id]
  subnets            = [aws_subnet.Subnet1.id, aws_subnet.Subnet2.id]

  tags = {
    name = "webgroup"
  }
}

# Creating Target Group

resource "aws_lb_target_group" "test" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# Creating Target group Attachment

resource "aws_lb_target_group_attachment" "TGA1" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "TGA2" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# Defining the listener Group

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.testLB.arn
  port              = "443"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

# Getting Output

output "loadbalancerdns" {
  value = aws_lb.testLB.dns_name
}
