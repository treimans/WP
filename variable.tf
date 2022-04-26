variable "region" {
  description = "Plese Enter AWS Region to deploy Server"
  type        = string
  default     = "us-east-1"
}
variable "instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t2.micro"
}
variable "commond_tags" {
  description = "Common Tags to apply to all resurces"
  type        = map(any)
  default = {
    Name    = "WP_sn"
    Billing = "internal"
    Owner   = "Sergey Treyman"
  }
}
