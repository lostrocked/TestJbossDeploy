variable "aws_access_key" {default = "AKIAJAWDGTHWN37HFJCQ"}
variable "aws_secret_key" {default = "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"}
//variable "aws_ami" {default = "ami-0080e4c5bc078760e"}
//variable "aws_ami" {default = "ami-07ebfd5b3428b6f4d"}
variable "aws_security_group_id" {default = "sg-9df8afed"}
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
	ami                    = "ami-07ebfd5b3428b6f4d"
	instance_type          = "t2.micro"
	vpc_security_group_ids = [aws_security_group_id]
	key_name	= "sachin-key-us-east-1"

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
		mkdir  /tmp/jenya
                cd /tmp/jenya
		git clone git://github.com/jenyss/requestbin.git
		cd requestbin
		docker-compose build
		docker-compose up -d
		cd /tmp
		printf '%s\n' '{"Source": "zhenya.stoeva@gmail.com", "Template": "MyTemplateJ_${local.in_id}", "ConfigurationSetName": "ConfigSet", "Destination": {"ToAddresses": [ "jenya.stoeva@broadcom.com"]}, "TemplateData": "{}"}' >myemail1.json
		export AWS_ACCESS_KEY_ID=${var.access_key} 
		export AWS_SECRET_ACCESS_KEY=${var.secret_key}
		export AWS_DEFAULT_REGION=us-east-1
		aws ses send-templated-email --cli-input-json file://myemail1.json
	HEREDOC
}

resource "aws_ses_template" "MyTemplateJ" {
	name    = "MyTemplateJ_${local.in_id}"
	subject = "Greetings, Jeny!"
	html    = "<h1>Hello Jeny,</h1><p>Your app url is http://${aws_instance.cda_instance.*.public_ip[0]}.</p>"
	text    = "Hello Jeny, Your app url is http://${aws_instance.cda_instance.*.public_ip[0]}."
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
