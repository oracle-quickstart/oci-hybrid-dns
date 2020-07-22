## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Variables
variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

# Specify any Default Value's here

variable "availability_domain" {
  default = "1"
}

variable "ad_number" {
  default     = 0
  description = "Which availability domain to deploy to depending on quota, zero based."
}

variable "ad_name" {
  default = ""
}
variable "AD" {
    default = "1"
}
variable "mgmt_subnet_cidr1" {
  default = "10.0.0.0/24"
}

variable "mgmt_subnet_cidr2" {
  default = "10.0.1.0/24"
}

variable "onprem_cidr" {
  default = "172.16.0.0/16"
}

variable "onprem_dns_zone" {
  default = "customer.net"
}

variable "onprem_dns_server1" {
  default = "172.16.0.5"
}

variable "onprem_dns_server2" {
  default = "172.16.31.5"
}

variable "vcn_cidr" { default = "10.0.0.0/16" }

variable "instance_shape" {
default = "VM.Standard2.4"
}
variable "InstanceImageOCID" {
    type = "map"
    default = {
        // Oracle-provided image "Oracle-Linux-7.4-2017.12.18-0"
        // See https://docs.us-phoenix-1.oraclecloud.com/Content/Resources/Assets/OracleProvidedImageOCIDs.pdf
        us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaasc56hnpnx7swoyd2fw5gyvbn3kcdmqc2guiiuvnztl2erth62xnq"
        us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaxrqeombwty6jyqgk3fraczdd63bv66xgfsqka4ktr7c57awr3p5a"
        eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaayxmzu6n5hsntq4wlffpb4h6qh6z3uskpbm5v3v4egqlqvwicfbyq"
    }
}

