terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.0"
   }
 }
 required_version = ">= 1.6.0"
}


provider "aws" {
 region = "us-east-1"
}


resource "aws_s3_bucket" "exercise" {
 bucket = "oyd-exercise-bucket-2026"


 tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "Isabel Paiz"
  }
}