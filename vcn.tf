## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

data "oci_identity_availability_domain" "ad1" {
  compartment_id = "${var.tenancy_ocid}"
  ad_number      = 1
}

data "oci_identity_availability_domain" "ad2" {
  compartment_id = "${var.tenancy_ocid}"
  ad_number      = 2
}

resource "oci_core_virtual_network" "CoreVCN" {
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "mgmt-vcn"
  dns_label      = "mgmtvcn"
}

resource "oci_core_internet_gateway" "MgmtIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MgmtIG"
  vcn_id         = "${oci_core_virtual_network.CoreVCN.id}"
}

resource "oci_core_route_table" "MgmtRouteTable" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.CoreVCN.id}"
  display_name   = "MgmtRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.MgmtIG.id}"
  }
}
resource "oci_core_security_list" "MgmtSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MgmtSecurityList"
  vcn_id         = "${oci_core_virtual_network.CoreVCN.id}"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 53
      min = 53
    }

    protocol = "6"
    source   = "${var.vcn_cidr}"
  }
  ingress_security_rules {
      udp_options {
        max = 53
        min = 53
      }

      protocol = "17"
      source   = "${var.vcn_cidr}"
    }
  ingress_security_rules {
      tcp_options {
        max = 53
        min = 53
      }

      protocol = "6"
      source   = "${var.onprem_cidr}"
    }
  ingress_security_rules {
      udp_options {
        max = 53
        min = 53
      }

      protocol = "17"
      source   = "${var.onprem_cidr}"
    }
  ingress_security_rules {
      protocol = "all"
      source   = "${var.vcn_cidr}"
    }
  ingress_security_rules {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        min = 22
        max = 22
      }
    }
  ingress_security_rules {
      protocol = "1"
      source   = "0.0.0.0/0"

      icmp_options {
        type = 3
        code = 4
      }
    }
}

resource "oci_core_dhcp_options" "MgmtDhcpOptions" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.CoreVCN.id}"
  display_name   = "MgmtDhcpOptions"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }
}

resource "oci_core_subnet" "MgmtSubnet" {
  availability_domain = "${data.oci_identity_availability_domain.ad1.name}"
  cidr_block          = "${var.mgmt_subnet_cidr1}"
  display_name        = "MgmtSubnet"
  dns_label           = "mgmtsubnet"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.CoreVCN.id}"
  route_table_id      = "${oci_core_route_table.MgmtRouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.MgmtSecurityList.id}"]
  dhcp_options_id     = "${oci_core_dhcp_options.MgmtDhcpOptions.id}"
}

resource "oci_core_subnet" "MgmtSubnet2" {
  availability_domain = "${data.oci_identity_availability_domain.ad2.name}"
  cidr_block          = "${var.mgmt_subnet_cidr2}"
  display_name        = "MgmtSubnet2"
  dns_label           = "mgmtsubnet2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.CoreVCN.id}"
  route_table_id      = "${oci_core_route_table.MgmtRouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.MgmtSecurityList.id}"]
  dhcp_options_id     = "${oci_core_dhcp_options.MgmtDhcpOptions.id}"
}


