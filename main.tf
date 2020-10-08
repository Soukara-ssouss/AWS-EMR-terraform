


#--------------------------------------------------------------
# Provider
#--------------------------------------------------------------

provider "aws" {
   access_key = "${var.ACCESS_KEY}"
   secret_key = "${var.SECRET_KEY}"
   region  = "${var.region}"
   version = "~> 2.0"
}




#--------------------------------------------------------------
# S3 Bucket
#--------------------------------------------------------------

resource "aws_s3_bucket" "bankdataset1" {
bucket = "bankdataset1"
 versioning {
enabled = true
   }
}

resource "aws_s3_bucket_object" "bankdatasetobject1" {
  bucket = "bankdataset1"
  key    = "bankdataset.csv"
  source = "~/AWS-EMR-terraform/bankdataset.csv"
  etag = filemd5("~/AWS-EMR-terraform/bankdataset.csv")

}

resource "aws_s3_bucket_object" "bankdatasetobject" {


  bucket = "bankdataset1"
  key    = "untitled1-assembly-0.1.jar"
  source = "~/AWS-EMR-terraform/untitled1-assembly-0.1.jar"
  etag = filemd5("~/AWS-EMR-terraform/untitled1-assembly-0.1.jar")

}
 
resource "aws_key_pair" "emr_key_pair" {
 key_name = "emr-key"
 public_key = file("~/AWS-EMR-terraform/myclusterkey.pub")

}





#--------------------------------------------------------------
# Security Groups
#--------------------------------------------------------------

resource "aws_security_group" "master_security_group" {
name= "master_security_group"
description= "Allow inbound traffic from VPN"
vpc_id="${aws_vpc.main_vpc.id}"
 
# Avoid circular dependencies stopping the destruction of the cluster
revoke_rules_on_delete = true
 
# Allow communication between nodes in the VPC
ingress {
from_port= "0"
to_port= "0"
protocol= "-1"
self= true
}
 
ingress {
from_port= "8443"
to_port= "8443"
protocol= "TCP"
}
 
egress {
from_port= "0"
to_port= "0"
protocol= "-1"
cidr_blocks= "${var.cidr_blocks_egress}"
}
 
  # Allow SSH traffic from VPN
ingress {
from_port= 22
to_port= 22
protocol= "TCP"
cidr_blocks= "${var.cidr_blocks_ingress}"
}

 #### Expose web interfaces to VPN

 
 # Spark History
ingress {
from_port= 18080
to_port= 18080
protocol= "TCP"
cidr_blocks= "${var.cidr_blocks_ingress}"
}
 
  # Spark UI
ingress {
from_port= 4040
to_port= 4040
protocol= "TCP"
cidr_blocks= "${var.cidr_blocks_ingress}"
}

 
lifecycle {
ignore_changes = ["ingress", "egress"]
}
 
}

	
resource "aws_security_group" "slave_security_group" {
name= "slave_security_group"
description= "Allow all internal traffic"
vpc_id= "${aws_vpc.main_vpc.id}"
revoke_rules_on_delete = true
 
  # Allow communication between nodes in the VPC
ingress {
from_port= "0"

to_port= "0"
protocol= "-1"
self= true
}
 
ingress {
from_port= "8443"
to_port= "8443"
protocol= "TCP"
}
 
egress {
from_port= "0"
to_port= "0"
protocol= "-1"
cidr_blocks= "${var.cidr_blocks_egress}"
}
 
  # Allow SSH traffic from VPN
ingress {
from_port= 22
 
to_port= 22
protocol= "TCP"
cidr_blocks= "${var.cidr_blocks_ingress}"
}
 
lifecycle {
ignore_changes= ["ingress", "egress"]
} 

}


#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------


resource "aws_vpc" "main_vpc" {
  cidr_block    = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    name = "emr_test"
  }
}



#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------


resource "aws_subnet" "main_subnet" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "${var.subnet_cidr}"

  tags = {
    name = "emr_test"
  }
}




#--------------------------------------------------------------
# Internet Gateway
#--------------------------------------------------------------


resource "aws_internet_gateway" "gw" {

  vpc_id = "${aws_vpc.main_vpc.id}"
}



#--------------------------------------------------------------
# Route Tables
#--------------------------------------------------------------


resource "aws_route_table" "r" {

  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}


resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.main_vpc.id}"
  route_table_id = "${aws_route_table.r.id}"
}



#--------------------------------------------------------------
# IAM role for EMR Service
#--------------------------------------------------------------




resource "aws_iam_role" "my_iam_emr_service_role" {
  name = "my_iam_emr_service_role"


  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "my_iam_emr_service_policy" {
  name = "my_iam_emr_service_policy"

  role = "${aws_iam_role.my_iam_emr_service_role.id}"
 

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CancelSpotInstanceRequests",
            "ec2:CreateNetworkInterface",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteTags",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeNetworkAcls",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribePrefixLists",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSpotInstanceRequests",
            "ec2:DescribeSpotPriceHistory",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeVpcEndpointServices",
            "ec2:DescribeVpcs",
            "ec2:DetachNetworkInterface",
            "ec2:ModifyImageAttribute",
            "ec2:ModifyInstanceAttribute",
            "ec2:RequestSpotInstances",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:DeleteVolume",
            "ec2:DescribeVolumeStatus",
            "ec2:DescribeVolumes",
            "ec2:DetachVolume",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:ListInstanceProfiles",
            "iam:ListRolePolicies",
            "iam:PassRole",
            "s3:CreateBucket",
            "s3:Get*",
            "s3:List*",
            "sdb:BatchPutAttributes",
            "sdb:Select",
            "sqs:CreateQueue",
            "sqs:Delete*",
            "sqs:GetQueue*",
            "sqs:PurgeQueue",
            "sqs:ReceiveMessage"
        ]
    }]
}
EOF
}

	# IAM Role for EC2 Instance Profile


#--------------------------------------------------------------
# IAM Role for EC2 Instance Profile
#--------------------------------------------------------------


resource "aws_iam_role" "iam_emr_profile_role" {
  name = "iam_emr_profile_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "emr_profile" {
  name  = "emr_profile"
  roles = ["${aws_iam_role.iam_emr_profile_role.name}"]
}

resource "aws_iam_role_policy" "iam_emr_profile_policy" {
  name = "iam_emr_profile_policy"
  role = "${aws_iam_role.iam_emr_profile_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "cloudwatch:*",
            "dynamodb:*",
            "ec2:Describe*",
            "elasticmapreduce:Describe*",
            "elasticmapreduce:ListBootstrapActions",
            "elasticmapreduce:ListClusters",
            "elasticmapreduce:ListInstanceGroups",
            "elasticmapreduce:ListInstances",
            "elasticmapreduce:ListSteps",
            "kinesis:CreateStream",
            "kinesis:DeleteStream",
            "kinesis:DescribeStream",
            "kinesis:GetRecords",
            "kinesis:GetShardIterator",
            "kinesis:MergeShards",
            "kinesis:PutRecord",
            "kinesis:SplitShard",
            "rds:Describe*",
            "s3:*",
            "sdb:*",
            "sns:*",
            "sqs:*"
        ]
    }]
}
EOF
}




#--------------------------------------------------------------
# Emr Cluster
#--------------------------------------------------------------

resource "aws_emr_cluster" "myEmr-spark-cluster" {
   name = "my-emr-cluster"
   release_label = "${var.release_label}"
   applications = "${var.applications}"


  termination_protection = false

  keep_job_flow_alive_when_no_steps = true


 ec2_attributes {
 subnet_id = "${aws_subnet.main_subnet.id}"
 emr_managed_master_security_group = "${aws_security_group.master_security_group.id}"
emr_managed_slave_security_group  = "${aws_security_group.slave_security_group.id}"   
  instance_profile = "${aws_iam_instance_profile.emr_profile.id}"
     key_name = "${aws_key_pair.emr_key_pair.key_name}"
      
   }

  master_instance_group {
    instance_type = "${var.instance_type}"
  }

  core_instance_group {
    instance_type  = "${var.instance_type}"
    instance_count = "${var.instance_count}"

    ebs_config {
      size                 = "${var.size}"
      type                 = "gp2"
      volumes_per_instance = 1
    }
}

  log_uri = "${var.log_uri}"

  service_role = "${aws_iam_role.my_iam_emr_service_role.id}"
}





