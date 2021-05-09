variable "region" {
  default = "us-west-2"
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
variable "ssl_policy" {
  description = "SSL Policy for HTTPS Listeners"
  type        = string

  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}


// us-east-1
variable "ami2" {
  type = map(string)

  default = {
    prod = "ami-0742b4e673072066f"
    dev = "ami-0742b4e673072066f"
    poc = "ami-0742b4e673072066f"
  }
}

// Oregon
variable "ami" {
  type = map(map(string))

  default = {
    us-west-2 ={
      prod = "ami-0742b4e673072066f"
      dev = "ami-0742b4e673072066f"
      poc = "ami-0cf6f5c8a62fa5da6"
  
    }
    us-east-1 ={
      prod = "ami-0742b4e673072066f"
      dev = "ami-0742b4e673072066f"
      poc = "ami-0742b4e673072066f"
  
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
  default = "password"
}

variable "db_username" {
  default = "postgres"
}

#----------- "equema" de KONG en postgress -----------
variable "kong_db_password" {
  default = "kong"
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


