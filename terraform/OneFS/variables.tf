variable "username" {
  type = string
  default = "root"
}

variable "password" {
  type = string
  default = "Test@1234"
}

variable "endpoint" {
  type = string
  default = "https://x.x.x.x:8080"
}

variable "insecure" {
  type = bool
  default = true
}
