resource aws_ebs_volume "v1"{
             size=10
             availability_zone="ap-southeast-1a"
             type="gp2"
             tags = {
    "Name" = "HelloWorld"
    "Env" = "Dev"
 }
}


resource "aws_eip" "myip" {
}


output "vlid"{
       value="aws_ebs_volume.v1.id"
}

output "x"{
       value="aws_ebs_volume.v1.arn"
}

