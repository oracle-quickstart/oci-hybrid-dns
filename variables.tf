## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "vcn_id" {
  type = string
  description = "The OCID of the existing VCN that will be used."
}
variable "compartment_id" {
  type = string
  description = "The compartment OCID to use for all created resources."
}
variable "subnet_cidr" {
  type = string
  description = "The CIDR to use for the hybrid DNS Subnet that will be made."
}
variable "subnet_route_table_id" {
  type = string
  description = "The OCID of the existing Route Table to use for the hybrid DNS Subnet."
}

variable "allow_vcn_cidr" {
  type = bool
  default = false
  description = "Whether or not to add NSG rules for the hybrid_dns NSG for the VCN CIDR (ingress/egress rules for DNS queries/reponses)."
}
variable "inbound_query_cidrs" {
  type = list(string)
  default = []
  description = "Additional CIDRs that should be added to the hybrid_dns NSG (as NSG rules) for DNS queries/responses."
}

variable "dns_forwarding_rules" {
  type = list(object({
    domain_name = string,
    forwarder_ip = string
  }))
  description = "The DNS namespaces and servers that respond to these namespaces."
}
variable "reverse_dns_mappings" {
  type = list(object({
    cidr   = string
    forwarder_ip = string
  }))
  description = "The reverse DNS namespaces and servers that respond to these reverse namespaces."
}
variable "existing_nsg_ids" {
  type = list(string)
  description = "The OCIDs of any existing NSGs that should have rules created to permit DNS requests/responses to/from the hybrid_dns NSG."
  default = []
}

variable "num_forwarders" {
  type = number
  default = 2
  description = "How many DNS forwarders should be built (1, 2 or 3)."
}
variable "instance_shape" {
  type = string
  description = "The shape to use for the hybrid DNS forwarders - see https://docs.cloud.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm for the list."
}
variable "default_img_name" {
  type = string
  description = "The image name to use for the hybrid DNS forwarders - see https://docs.cloud.oracle.com/en-us/iaas/images/ for the list."
}
variable "default_ssh_auth_keys" {
  type = list(string)
  description = "The full path to the public SSH keys to install on each hybrid DNS compute instance."
}

variable "tenancy_id" {
  type = string
  description = "The OCID of the tenancy to use."
}
variable "user_id" {
  type = string
  description = "The OCID of the OCI user account to use."
}
variable "fingerprint" {
  type = string
  description = "The fingerprint for the given user account (and API key)."
}
variable "private_key_path" {
  type = string
  description = "The full path to the private API key to use for the given user account."
}
variable "region" {
  type = string
  description = "The OCI region identifier to use.  See https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm for the list."
}
