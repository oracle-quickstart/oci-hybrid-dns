## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  search_domain_names = [data.oci_core_vcn.this.vcn_domain_name]
}

resource "oci_core_dhcp_options" "vcn_dns" {
  compartment_id = var.compartment_id
  options {
    type = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }
  options {
    type = "SearchDomain"
    search_domain_names = [ data.oci_core_vcn.this.vcn_domain_name ]
  }
  vcn_id = var.vcn_id
  display_name = "vcn_dns"
}

resource "oci_core_dhcp_options" "hybrid_dns" {
  compartment_id = var.compartment_id
  options {
    type = "DomainNameServer"
    server_type = "CustomDnsServer"
    custom_dns_servers = flatten(concat(oci_core_instance.this.*.private_ip))
  }
  
  options {
    type = "SearchDomain"
    search_domain_names = local.search_domain_names
  }
  
  vcn_id = var.vcn_id
  display_name = "hybrid_dns"
}
