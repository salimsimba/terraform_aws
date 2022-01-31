variable "app_container_name" { default = "service" }

variable "app_container_port" { default = 5000 }

variable "app_image_name" { default = "koffeeluv:latest" }

variable "app_repository_branch" { default = "master" }

variable "app_ecr_repository_name" { default = "koffeeluv" }

variable "aws_region" { default = "us-east-1" }

variable "contact" { default = "salimsimba@hotmail.com" }

variable "key_name" { default = "myec2key" }

variable "prefix" { default = "koffeeluv" }

variable "project" { default = "Koffee Luv liveProject" }
