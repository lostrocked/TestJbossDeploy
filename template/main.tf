variable "aws_access_key" {default = "AKIAJAWDGTHWN37HFJCQ"}
variable "aws_secret_key" {default = "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"}
variable "aws_security_group_id" {default = "sg-01a2407a79391adca"}
variable "instance_type" {default = "t2.micro"}
locals {
	in_id = "${random_string.password.result}"
}

resource "random_string" "password" {
  length = 10
  special = false
}

provider "aws" {
	region     = "us-east-1"
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
}

resource "aws_instance" "cda_instance" {
	ami                    = "ami-098f16afa9edf40be"
	instance_type          = "t2.micro"
	vpc_security_group_ids = [
        			"sg-01a2407a79391adca",
        ]
	key_name	= "hayabusa"
	subnet_id = "subnet-9df4e8a3"

	user_data = <<HEREDOC
		#!/bin/bash
		yum update -y
		yum install -y docker
		service docker start
		usermod -aG docker ec2-user
		curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose	
		chmod +x /usr/local/bin/docker-compose
		sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
		yum install -y git
		mkdir  /tmp/demoim
                cd /tmp/demoim
		git clone git://github.com/jenyss/requestbin.git
		cd requestbin
		docker-compose build
		docker-compose up -d
		cd /tmp
		printf '%s\n' '{"Source": "lostrocked3@gmail.com", "Template": "MyTemplateJ_${local.in_id}", "ConfigurationSetName": "ConfigSet", "Destination": {"ToAddresses": [ "sachin.srivastava@broadcom.com"]}, "TemplateData": "{}"}' >myemail1.json
		export AWS_ACCESS_KEY_ID=${var.access_key} 
		export AWS_SECRET_ACCESS_KEY=${var.secret_key}
		export AWS_DEFAULT_REGION=us-east-1
		aws ses send-templated-email --cli-input-json file://myemail1.json
	HEREDOC
}

resource "aws_ses_template" "MyTemplateJ" {
	name    = "MyTemplateJ_${local.in_id}"
	subject = "Greetings, Master Williams!"
	html    = "<h1>Hello Master Williams,</h1><p>Your app url is http://${aws_instance.cda_instance.*.public_ip[0]}.</p>"
	text    = "Hello Master Williams, Your app url is http://${aws_instance.cda_instance.*.public_ip[0]}."
}

output "public_ip" {
	description = "List of public IP addresses assigned to the instances, if applicable"
	value = "${aws_instance.cda_instance.*.public_ip[0]}"
}

output "id" {
	description = "List of IDs of instances"
	value       = "${aws_instance.cda_instance.*.id[0]}"
}

output "availability_zone" {
	description = "List of availability zones of instances"
	value       = "${aws_instance.cda_instance.*.availability_zone[0]}"
}

output "key_name" {
	description = "List of key names of instances"
	value       = "${aws_instance.cda_instance.*.key_name[0]}"
}

output "public_dns" {
	description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
	value       = "${aws_instance.cda_instance.*.public_dns[0]}"
}
