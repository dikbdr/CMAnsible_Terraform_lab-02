# project 2 Learning about terraform variables
# variable example
/*
 variable "Variable_name" {
    description  = "Variable description"
    type         = varibale type #/ string, number, list, map, 
    default      = "t2.micro"   # default value of variable
}*/

# creating provide block
provider "aws" {
  region  = "us-west-2"
   access_key = "tt" # keys.my-access-key
   secret_key = "tt/yGuKttsiMlM" #keys.my-secret-key
}

# creating resource block
resource "aws_instance" "vm_project2" {
    ami           = "ami-0606dd43116f5ed57" #"ami-00c257e12d6828491"
    instance_type = var.instance_type
    count = var.instance_count
    associate_public_ip_address = var.enable_public_ip

    tags = { 
            Name = var.project_env["project"]
    }
    
}
# output the Public ip of the Instance
#output "instance_ip" {
   # value = aws_instance.vm_project2.public_ip[1]
#}

# creating I am users using variables values
resource "aws_iam_user" "iam_user" {
  count = length(var.users_name)
  name  = var.users_name [count.index]
}



# Creating variable block for Instance type
variable "instance_type" {
    description  = "Instance type t2.micro"
    type         = string
    default      = "t2.micro"
}

# creating variable block for Instance numbers
variable "instance_count" {
    description     = "EC2 Instance count"
    type            = number
    default         = 1
}

#creating variabel block for enabling public ip
variable "enable_public_ip" {
    description     = "Enable the Public IP"
    type            = bool
    default         = true
}

# creating user, using list type varible
variable "users_name" {
    description = "Iam Users names"
    type        = list(string)
    default     = ["user1", "user2", "user3"]
}

# creating map variable
variable "project_env" {
    description     = "Project environment for tag"
    type            = map(string)
    default         = {
      "project"       = "Test_project",
      "environment"   = "Test_env"
    }
}
