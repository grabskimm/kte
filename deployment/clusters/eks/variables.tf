variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  description = "AWS profile"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}