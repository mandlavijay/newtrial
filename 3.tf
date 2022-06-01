resource aws_security_group "sg-1"{
     vpc_id  =aws_vpc.vpc1.id
	 name  = "sg-1"
	 description = "sg-1"
	 ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [0.0.0.0/0,23.90.10.90/32,56.90.89.90]
    
  }
   ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [0.0.0.0/0]
    
  }
   tags = {
    Name = "sg-1"
  }
}
resource aws_instance "i1"{
     ami="ami-04d9e855d716f9c99"
     instance_type="t2.micro"
	 vpc_security_group_ids=[aws_security_group.sg-1.id]
     subnet_id   = aws_subnet.SN1-PUB.id
	 tags = {
    Name = "i1"
  }
}
resource "aws_elb" "elbclass" {
     name= "elbclass"
	 subnets=[aws_subnet.SN1-PUB.id,aws_subnet.SN2-PUB.id]
	 
	 listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 10
  }
    tags = {
    Name = "elbclass"
  }
  access_logs {
    bucket        = "aws_s3_bucket.b1.name"
    bucket_prefix = "elbl"
    interval      = 60
  }
}
resource aws_instance "i2-pvt"{
     ami="ami-04d9e855d716f9c99"
     instance_type="t2.micro"
	 vpc_security_group_ids=[aws_security_group.sg-1.id]
     subnet_id   = aws_subnet.SN3-pvt.id
	 user_data=file("./1.sh")
	 tags = {
    Name = "i2-pvt"
  }
}
resource aws_instance "i3-pvt"{
     ami="ami-04d9e855d716f9c99"
     instance_type="t2.micro"
	 vpc_security_group_ids=[aws_security_group.sg-1.id]
     subnet_id   = aws_subnet.SN4-pvt.id
	 user_data=file("./1.sh")
	 tags = {
    Name = "i3-pvt"
  }
}
resource "aws_elb_attachment" "elbattach" {
  elb      = aws_elb.elbclass.id
  instance = aws_instance.SN1-PUB.id
}
resource "aws_elb_attachment" "elbattach" {
  elb      = aws_elb.elbclass.id
  instance = aws_instance.SN2-PUB.id
}
resource "aws_s3_bucket" "b1" {
  bucket = "vijay-624"
  acl    = "public-read-write"
  tags = {
    Name        = "mybucket"
    Environment = "Dev"
  }
}

