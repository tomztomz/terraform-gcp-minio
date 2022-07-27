variable "project" { 
    default = "your project id"
 }

variable "credentials_file" { 
    default = "your gcp service account.json"
 }

variable "region" {
    default = "asia-southeast1"
}

variable "zone" {
    default = "asia-southeast1-b"
}

variable "instance_name" {
    default = "your instance name"
}


variable "startup_script" { 
  default = "minio.sh"
}

variable "username" {
  default = "your ssh username"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  default = "~/.ssh/id_rsa"
}

