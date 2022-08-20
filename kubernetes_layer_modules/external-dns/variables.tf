
variable "primary_domain" {
    type    = string
    description = "The root domain name of the example api application server"
}

variable "dns_identifier"   {
    type = string
    description = "A unique identofoer for the DNS record, associated with this deployment"
}