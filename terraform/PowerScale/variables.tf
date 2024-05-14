variable "username" {
  type = string
  default = "root"
}

variable "password" {
  type = string
  default = "Password123!"
}

variable "endpoint" {
  type = string
  default = "https://192.168.1.21:8080"
}

variable "insecure" {
  type = bool
  default = true
}
