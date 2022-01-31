variable "destRegion" { default = "us-west-2" }

variable "loadFileName" { default = "./resources/koffee_luv_drink_menu.csv" }

variable "backupFileName" { default = "koffee_luv_drink_menu.csv" }

variable "contact" { default = "salimsimba@hotmail.com" }

variable "prefix" { default = "koffeeluv" }

variable "project" { default = "Koffee Luv liveProject" }

variable "dstBucketName" { default = "mcgannss-koffeeluv-s3-repl-dst-bucket" }

variable "srcBucketName" { default = "mcgannss-koffeeluv-s3-repl-src-bucket" }

variable "dynamodbDbName" { default = "koffee-menu-database" }
