variable "prefix" {
    type = string
    default = "gmtest"
}

variable "location" {
    type = string
    default = "uksouth"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "functionapp" {
    type = string
    default = "./build/functionapp.zip"
}

variable "subscriptionid" {
    type = string
}

resource "random_string" "storage_name" {
    length = 24
    upper = false
    lower = true
    number = true
    special = false
}