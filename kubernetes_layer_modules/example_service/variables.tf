variable "client"   {
    type = string
    description = "Name of example service client."
}


variable "namespace"  {
    type    = string
    description = "The namespce used by the service"
}


variable "pod_env_variables"    {
    type = map
    description = "The environmental variables used when launching the pod"
}

variable "ecr_image_location"   {
    type = string
    description = "Location of ECR image for the example service."
}

variable "example_port"   {
    type = number
    description = "The port to the service into the example service"
}


variable "database_connection_string"    {
    type = string
    description ="The connection url to the MongoDB Database"
}

variable "example_resource_limit" {
    type = map(string)
    description  = "Map with elements memory (Mi) and cpu(m) limits for the application pod"
}

variable "pod_replicas_settings" {
    type = map(number)
    description = "Map containing {max_replicas = xx, min_replicas = yy, target_cpu_utilization_percentage = zz%}"
}


variable "health_check_path"    {
    type = string
    description = "The path parameters of the healh check endpoint"
}