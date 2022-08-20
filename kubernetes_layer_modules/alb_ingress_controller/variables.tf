variable account_number {
    type = string
    description = "This is the number of the development account which owns the AMI that will be used"
}


variable eks_oicd_connect_info  {
    type = map
    description = "This information is used to connect the OICD providor with EKS for K8S service accounts. The format of this is a follows {eks_cluste_rname, thumbprint, issuer_url}"
}

// # The following variable are used to create computing instances
variable "region" {
    type    = string
   
}

variable "alb_name" {
    type = string
    description = "The name of the ALB"
}

variable "cluster_autoscaler_name" {
    type = string
    description = "The name of the cluster auto scaler"
}

variable "vpc_id" {
    type = string
    description = "This is the id of the vpc created in the network module"
}


variable "subnet_map" {
    type = map
    description = "The map of all subnets."
}


variable "security_group_map" {
    type = map
    description = "Map of all security groups."
}

variable "primary_domain" {
    type    = string
    description = "The root domain name of the example api application server"
}

variable  "primary_domain_host_zone_id" {
    type = string
    description = "This is the zone ID of the host zone for the domain"
}

variable "api_subdomain"  {
    type    = string
    description = "The subdomain to be used with the primary domain"
}


variable "service_name"  {
    type    = string
    description = "The application service name"
}


variable "example_port"   {
    type = number
    description = "The port to the service into the http_measurements service"
}


variable "example_namespace"  {
    type    = string
    description = "The namespce used by the service"
}

variable "tags"    {
    type = map
    description = "The maps of default tags"
}

variable waf_rules_arn   {
    description = "WAF rules to be used with the ALB"
}

variable acm_certificate_arn    {
    description = "ARN for SSL certificate"
}
