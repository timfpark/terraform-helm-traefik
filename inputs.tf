variable "helm_install_timeout" {
  default = 1800
}

variable "ingress_replica_count" {
  type    = "string"
  default = "3"
}

variable "prometheus_enabled" {
  type    = "string"
  default = "true"
}

variable "ssl_enabled" {
  type    = "string"
  default = "false"
}

variable "ssl_enforced" {
  type    = "string"
  default = "false"
}

variable "ssl_cert_base64" {
  type    = "string"
  default = ""
}

variable "ssl_key_base64" {
  type    = "string"
  default = ""
}
