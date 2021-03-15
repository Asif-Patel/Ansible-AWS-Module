
////////// #EC2 Key Pair //////////
resource "aws_key_pair" "interview-terraform-150321151631" {
  key_name   = "interview-terraform-150321151631"
  public_key = "ssh-rsa "
}

////////// #IAM Instance Profile //////////
resource "aws_iam_instance_profile" "interview-terraform-150321151631-IAM-profile" {
  name = "interview-terraform-150321151631-IAM-profile"
  role = aws_iam_role.interview-terraform-150321151631-IAM-role.name
}

resource "aws_iam_role" "interview-terraform-150321151631-IAM-role" {
  name = "interview-terraform-150321151631-iam-role"
  path = "/"
  #tags = {
  #  Name = "interview-terraform-150321151631"
  #}
  #managed_policy_arns = [ "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonSSMFullAccess" ]
  inline_policy {
   name = "S3_bucket_putobject_policy"
   policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObject*"
            ],
            "Resource": "*"
        }
    ]
    })
 }
 assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

////////// #Security Groups //////////
resource "aws_security_group" "interview-terraform-150321151631-app-sg" {
  name        = "interview-terraform-150321151631-app-sg"
  description = "Allow SSH inbound traffic"
  ingress {
    description = "SSH access to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "interview-terraform-150321151631"
  }
}

resource "aws_instance" "interview-terraform-150321151631-ec2-server" {
    depends_on = [
      aws_security_group.interview-terraform-150321151631-app-sg, aws_key_pair.interview-terraform-150321151631, aws_iam_instance_profile.interview-terraform-150321151631-IAM-profile
    ]
  instance_type = "t2.nano"
  ami = "ami-9dcfdb8a"
  iam_instance_profile = aws_iam_instance_profile.interview-terraform-150321151631-IAM-profile.name
  key_name = aws_key_pair.interview-terraform-150321151631.id
  security_groups = [ aws_security_group.interview-terraform-150321151631-app-sg.id ]
  subnet_id = "subnet-XXXXXXXXX"
  tags = {
    Name = "interview-cfn-150321151631"
  }
}

output "instance_id" {
    depends_on = [
      aws_instance.interview-terraform-150321151631-ec2-server
    ]
    value = aws_instance.interview-terraform-150321151631-ec2-server.id
}

output "instance_server_ip" {
    depends_on = [
      aws_instance.interview-terraform-150321151631-ec2-server
    ]
    value = aws_instance.interview-terraform-150321151631-ec2-server.public_ip
}