## ALB Module

This module is created to spin up application load balancers

Please not this module is not compatible with terraform version less than 0.12.x.

## Inputs

| Name | Description | Type | Default | Required |
|------|-----------------------------------------------------|--------|---------|----------|
|lb_name| A unique name for your alb | string | "" | Yes|
| vpc_id | The VPC Id in which resources will be provisioned. Default is the default AWS vpc | string | vpc-xxxxx | Yes |
| private_subnets | A set of subnet ID's that will be associated with the Farage service. By default the module will use the default vpc's private subnets. | list(string) | ["subnet-xxx"] | No |
| public_subnet_ids | A set of subnet ID's that will be associated with the Farage service. By default the module will use the default vpc's public subnets. | list(string) | ["subnet-xxx"] | No |
| certificate_arn | A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http | string | "" | No |

## Outputs


| Name | Description |
|------|-------------|
| target_group_arn | The full Amazon Resource Name (ARN) of the application load balancer |
| fargate_sg | The security group associated with the alb |