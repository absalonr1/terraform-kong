variable "region" {
  default = "us-west-2"
  #default = "us-east-1"
}

variable "health_check_interval" {
  description = "Seconds between health checks"
  type        = string

  # Terraform default is 30
  default = 5
}

variable "health_check_matcher" {
  description = "HTTP Code(s) that result in a successful response from a target (comma delimited)"
  type        = string

  default = 200
}

variable "health_check_timeout" {
  description = "Seconds waited before a health check fails"
  type        = string

  # Terraform default is 5
  default = 3
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutives checks before a unhealthy target is considered healthy"
  type        = string

  # Terraform default is 5
  default = 5
}
variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive checks before considering a target unhealthy"
  type        = string

  # Terraform default is 2
  default = 2
}

variable "idle_timeout" {
  description = "Seconds a connection can idle before being disconnected"
  type        = string

  # Terraform default is 60
  default = 60
}
variable "key_pair" {
  description = "Para acceso SSH a las instancias EC2"
  type        = string

  # Terraform default is 60
  default = "kong-key-pair"
}


// Oregon
variable "ami" {
  type = map(map(string))

  default = {
    us-west-2 ={
      prod = "ami-0cf6f5c8a62fa5da6"
      dev = "ami-0cf6f5c8a62fa5da6"
      poc = "ami-0cf6f5c8a62fa5da6"
  
    }
    us-east-1 ={
      prod = "ami-0d5eff06f840b45e9"
      dev = "ami-0d5eff06f840b45e9"
      poc = "ami-0d5eff06f840b45e9"
  
    }
  }
}



# https://docs.konghq.com/enterprise/2.3.x/sizing-guidelines/
variable "instance_type" {
  type = map(string)

  default = {
    prod = "m5.large"
    dev = "t2.micro"
    poc = "t2.micro"
  }
}

# https://docs.konghq.com/enterprise/0.32-x/kong-implementation-checklist/
variable "db_instance_type" {
  type = map(string)

  default = {
    prod = "db.r6g.large"
    dev = "db.m6g.large"
    poc = "db.t2.micro"
  }
}

variable "environment" {
  type = string

  default = "poc"
  #default = "prod"
  #default = "dev"

}

variable "db_password" {
  default = "3uF6nBrcv8Q5qeD8"
}

variable "db_username" {
  default = "postgres"
}

#----------- "equema" de KONG en postgress -----------
variable "kong_db_password" {
  default = "g2YDHdAmLpnQW9bg"
}

variable "kong_db_username" {
  default = "kong"
}

variable "kong_db" {
  default = "kong"
}
#-----------------------------------------------------


# Postgres
variable "db_engine_version" {
  default = "11.5"
}

variable "subnets"{
   type = map(map(string))
   default = {
    0 = {
      cidr ="10.10.0.0/27"
      #az = "us-east-1a"
    }
    1 = {
      cidr ="10.10.0.32/27"
      #az = "us-east-1b"
    }
  }
}

variable "subnets_lbaas"{
   type = map(map(string))
   default = {
    0 = {
      cidr ="10.10.0.64/27"
      #az = "us-east-1a"
    }
    1 = {
      cidr ="10.10.0.96/27"
      #az = "us-east-1b"
    }
  }
}

variable "availability_zones"{
   #type = map(map(list))
   default = {
    us-east-1 = {
      zones = ["us-east-1a","us-east-1b"]
    }
    us-west-2 = {
      zones = ["us-west-2a","us-west-2b"]
    }
  }
}


variable "kong_vm_instance_count"{
  default = 2
}

variable "ssl_policy" {
  description = "SSL Policy for HTTPS Listeners"
  type        = string

  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "ssl_cert_external" {
  description = "SSL certificate domain name for the external Kong Proxy HTTPS listener"
  type        = string
  default = "qaapigw.bluex.cl"
}
