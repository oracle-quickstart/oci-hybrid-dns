## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_subnet" "this" {
  vcn_id                     = var.vcn_id
  cidr_block                 = var.subnet_cidr
  compartment_id             = var.compartment_id
  display_name               = "dns_forwarders"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "dns"
  availability_domain        = null
  dhcp_options_id            = oci_core_dhcp_options.vcn_dns.id
  route_table_id             = var.subnet_route_table_id
}
