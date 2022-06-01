/*
1)create Ec2 instance
2)Create 10 GB Volume in Same AZ as Ec2 instance
3)Attach Volume to Ec2 instance
4)Create EIP and Attach to Ec2 Instance
*/
/*
resource aws_instance "i1"{
     ami="ami-04d9e855d716f9c99"
     instance_type="t2.micro"
     subnet_id="subnet-0b153b1705f0d8387"
}
resource aws_ebs_volume "v1"{
       availability_zone=aws_instance.i1.availability_zone
       size=10
       type="gp2"
}
resource aws_volume_attachment "i1v1"{
    instance_id=aws_instance.i1.id
    volume_id=aws_ebs_volume.v1.id
    device_name="/dev/sdf"
}
resource aws_eip "eip1"{
      instance=aws_instance.i1.id
}
output "i1id"{
     value=aws_instance.i1.id
}
output "i1az"{
     value=aws_instance.i1.availability_zone
}
output "i1prvip"{
     value=aws_instance.i1.private_dns
}
*/

/*
1)Create a VPC in AWS sing Region.
2)Divide the vpc into 2 public subnets and 2 private subnets acros multiple availability zones.
       10.0.0.0/26 --->SN1  (ap-southeast-1a)
       10.0.0.64/26--->sn2  (ap-southeast-1b)
       10.0.0.128/26---->sn3 (ap-southeast-1a)
       10.0.0.192/26--->sn4   (ap-southeast-1b)
3)Create NATGATEWAY attach ec2 private subnets
4)Create SG in side VPC Allow Below Rules
           IB :
                  22 --->56.90.89.90
                  80---> 0.0.0.0/0
5)Launch Ec2 instance in public subnet(sn1)  Attach step4 SG
6)create classic ELB in Public Subnets
7)Launch Ubuntu Ec2 Instance in Private Subnets & install apache2
8)Attach Instances to ELB
9)Create s3 Bucket
10)Enable ELB accesslogs to store in step9 s3 Bucket
11)Print ELB DNS Name
*/

resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc1"
  }
}
resource "aws_subnet" "SN1-PUB"	{
      vpc_id  =aws_vpc.vpc1.id
      availability_zone="ap-southeast-1a"
      cidr_block="10.0.0.0/18"
tags = {
    Name = "SN1-PUB"
  }
}
resource "aws_subnet" "SN2-PUB"	{
      vpc_id  =aws_vpc.vpc1.id
       availability_zone="ap-southeast-1b"
      cidr_block="10.0.64.0/18"
tags = {
    Name = "SN2-pub"
  }
}
resource "aws_subnet" "SN3-pvt"	{
      vpc_id  =aws_vpc.vpc1.id
      cidr_block="10.0.128.0/18"
      availability_zone="ap-southeast-1a"
tags = {
    Name = "SN3-pvt"
  }
}
resource "aws_subnet" "SN4-pvt"	{
      vpc_id  =aws_vpc.vpc1.id
      cidr_block="10.0.192.0/18"
      availability_zone="ap-southeast-1b"
tags = {
    Name = "SN4-pvt"
  } 

}

resource "aws_internet_gateway" "igw-vpc1" {
         vpc_id=aws_vpc.vpc1.id
     tags = {
    Name = "igw_vpc1"
  } 
}

resource "aws_route_table" "rt1" {
           vpc_id = aws_vpc.vpc1.id
    tags = {
    Name = "rt-vpc1-pub1"
  } 

}

resource "aws_route" "rt1-igw"{
    route_table_id=aws_route_table.rt1.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.igw-vpc1.id

}

resource "aws_route_table_association" "sn1rt1" {
  subnet_id      = aws_subnet.SN1-PUB.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_route_table_association" "sn2rt1" {
  subnet_id      = aws_subnet.SN2-PUB.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_eip" "eipeip" {
        
       tags = {
    Name = "eip-alloc"
  } 
}




resource "aws_nat_gateway" "nate-vpc1" {
  
 
  subnet_id         = aws_subnet.SN1-PUB.id
  allocation_id=aws_eip.eipeip.id
tags = {
    Name = "nate-vpc1"
  } 

}
resource "aws_route_table" "rt2" {
           vpc_id = aws_vpc.vpc1.id
    tags = {
    Name = "rt-vpc1-pvt1"
  } 

}


resource "aws_route" "rt2-nat"{
    route_table_id=aws_route_table.rt2.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id =aws_nat_gateway.nate-vpc1.id

}

resource "aws_route_table_association" "sn3rt2" {
  subnet_id      = aws_subnet.SN3-pvt.id
  route_table_id = aws_route_table.rt2.id
}
resource "aws_route_table_association" "sn4rt2" {
  subnet_id      = aws_subnet.SN4-pvt.id
  route_table_id = aws_route_table.rt2.id
}
    
