## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_vcn" "this" {
  vcn_id = var.vcn_id
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy_id
}

data "oci_identity_fault_domains" "this" {
  count = length(data.oci_identity_availability_domains.this.availability_domains)
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[count.index].name
  compartment_id = var.tenancy_id
}

data "oci_core_images" "this" {
  compartment_id = var.compartment_id

  filter {
    name   = "state"
    values = ["AVAILABLE"]
  }
}
