variable "lb_name" {
     type        = string
  description = "Required; A unique name for alb"
  }

  variable "vpc_id" {
  type        = string
  description = "Optional; The VPC Id in which resources will be provisioned. Default is the default AWS vpc."
  default     = "vpc-0784feee283d827ab"// "vpc-0928dbf5d6ea7aa73"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Optional; A set of subnet ID's that will be associated with the Farage service. By default the module will use the default vpc's public subnets."
  default     = ["subnet-02bfbf99cdabab086", "subnet-0bcd16c3e147d5c98"]//["subnet-0d5a87b1da974abda", "subnet-0e189fca847b40e55"] //["subnet-02bfbf99cdabab086", "subnet-0bcd16c3e147d5c98"]
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "Optional; A set of subnet ID's that will be associated with the Application Load-balancer. By default the module will use the default vpc's public subnets."
  default     = ["subnet-0b9234f55a91961b6", "subnet-0e68d8c75ef8de658"] // ["subnet-017b0f619d72adf2b", "subnet-0b3f235dfaaefcfa2"] //["subnet-0b9234f55a91961b6", "subnet-0e68d8c75ef8de658"]
}

variable "alb_log_bucket_name" {
  type        = string
  description = "Optional; The S3 bucket name to store the ALB access logs in. Default is null."
  default     = null
}
variable "alb_log_prefix" {
  type        = string
  description = "Optional; Prefix for each object created in ALB access log bucket. Default is null."
  default     = null
}
variable "container_port" {
  type        = number
  description = "Optional; the port the container listens on."
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Optional; A relative path for the services health checker to hit. By default it will hit the root."
  default     = "/"
}

variable "certificate_arn" {
  type        = string
  description = "Optional; A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http."
  default     = null
}