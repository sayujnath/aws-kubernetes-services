// # ################ AWS SSL CERTIFICATE FOR LOAD BALANCER ################

resource "aws_acm_certificate" "alb_ssl_primary_cert" {
    
    domain_name       = var.primary_domain
        subject_alternative_names = [
        "${var.api_subdomain}.${var.primary_domain}"
    ]

    validation_method = "DNS"

    tags = {
        Name = join("-", [var.alb_name,"ssl-cert"])
    }
    lifecycle {
        create_before_destroy = true
        ignore_changes = [subject_alternative_names]
    }
}

resource "aws_route53_record" "cert_primary_verify" {
    for_each = {
        for dvo in aws_acm_certificate.alb_ssl_primary_cert.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
        }
    }
    
    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = each.value.type
    zone_id         = var.primary_domain_host_zone_id
}