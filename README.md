# terraform-aws-EMR
This repository contains Terraform configuration for AWS EMR cluster.

### Requirement 

| Name | Version |
| ------ | ------ |
| Terraform | >= 0.12.0 |
| AWS | ~> 2.0 |



### Installation

Download Terraform from the https://www.terraform.io/downloads.html . Select the appropriate package for your operating system and architecture, unzip the archive and move the binary to a directory included in your PATH variable.
To install Terraform on Ubuntu.
Visit the Terraform download page for the latest version to download.
```sh
$ wget https://releases.hashicorp.com/terraform/0.12.28/terraform_v0.12.28_linux_amd64.zip
```
Unzip the archive. The archive will extract a single binary called terraform, then Move the terraform binary to ~/bin directory.
```sh
$ unzip terraform_v0.12.28_linux_amd64.zip
$ mv terraform ~/bin
```
To check whether Terraform is installed, run:
```sh
$ terraform version
# Terraform v0.12.28
```
##### Generate AWS credentials for Terraform
Let’s deal with IAM to create user and get credentials that we will be using for creating or accessing AWS resources through terraform .

  - Click on Users and Add user,then name it
  - Select access type Programmatic access
   - Then select third tab Attach existing policies directly
   - Give AdministratorAccess and click Create user
   - Copy the Access key ID and Secret access key in safe place. You may also download .csv file 
  
## Usage 
After cloning the repository you'll notice tree fils with extention .tf
- main 
- variable
- output

Before running terraform commands you'll need to make some changes :
1  .First, you need to add your AWS credentials to variables file 

 ```sh
 $ cd terraform-AWS-Emr
$ nano variables.tf
```

```sh
variable "ACCESS_KEY" {
default = "***********"
}
variable "SECRET_KEY" {
default = "****************"
}
```
then to save changes press  
```sh
Caps locks -> O + CTRL -> Enter
```
to exit variables file press 
```sh
Caps locks -> X + CTRL 
```

2 .Then you need to create a key pair, by runnig the following command
which will allow you to enter location and the name of the key .
 ```sh
$ ssh-keygen -t rsa
```
After creating the key pair you'll need to add the its location to main file
 ```sh
$ resource "aws_key_pair" "emr_key_pair" {
 key_name = "emr-key"
 public_key = file("~/keyCluster.pub")
}
```
3 .The security group should allow the nodes to communicate with the master node, as well as to be accessed via certain ports from your personal VPN.
therefore add your public address with subnet /16, to cidr_blocks_ingress (default) in variables file.
 ```sh
variable "cidr_blocks_ingress" {
default = ["151.56.0.0/16"]
}
```


that would be all the necessary changes, although if you want to use a different region or change the configuration that can be done as well by editing the default parametres in variables file 

##### inputs  
* Variables file



| Name | Descreption |
| ------ | ------ |
| release_label |  The release label for the Amazon EMR release ( default = "emr-5.30.0") |
| instance_type |  Type of instances used in the cluster (default = "m5.xlarge")| 
| instance_count | Number of core instances (default = 2) |
| log_uri | The path to the Amazon S3 location where logs for this cluster are stored  |
| applications |  A list of EMR release applications (default = ["Spark"]) |
| subnet_cidr | The cidr block of the desired subnet |
| vpc_cidr | The cidr block of the desired VPC |
| cidr_blocks_egress | cider blocks used in outbound rule |
| cidr_blocks_ingress | cider blocks used in inbound rule to allow ssh into the instance|
| region |  AWS region in which the resources will be created   (default="eu-central-1")|
|  size| Root device EBS volume (default = size 40)|

##### Output
* Output file

| Name | Descreption |
| ------ | ------ |
| master_public_dns  |  The public DNS of the master EC2 instance|



##### Terraform commands 


Run the following commands to make sure that your setup is valid:
```sh
$ terraform init
$ terraform plan
```
If there are no errors, you can run the following to create the cluster:
```sh
$ terraform apply
```
in case you get an Error putting object in S3 bucket you may need to retry running terraform apply commande.
when you apply the configuration you well get the cluster created as well as an output displayed on the terminal which is the dns of the master node that you will use to connect to the instance.
to ssh into the master node use the following commande with the displayed dns

```sh
$ ssh -i ~/keyCluster haddop@ec2-18-191-105-47.eu-central-1.compute.amazonaws.com 
```
then after connecting to the instance use the following commande to launch a spark job.

```sh
$ spark-submit --master yarn --class "Classification1.Classification1" s3://bankdataset1/untitled1-assembly-0.1.jar 
```
To take down all the terraformed infrastructure run the following:
```sh
$ terraform destroy 
```

