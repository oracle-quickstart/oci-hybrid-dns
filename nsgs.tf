## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  dns_forwarder_ips = distinct(concat(
    [for i in var.dns_forwarding_rules:
      i.forwarder_ip
    ],
    [for i in var.reverse_dns_mappings:
      i.forwarder_ip
    ]
  ))
  
  # NSG rules (for when a bastion NSG is created)
  nsg_ingress_rules_temp = concat([for i in var.inbound_query_cidrs :
    {
      description = "Allow DNS queries from ${i}"
      stateless   = true
      protocol    = "17"
      src_type    = "CIDR_BLOCK"
      src         = i
      dst_port = {
        min = "53"
        max = "53"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ], [for i in local.dns_forwarder_ips :
    {
      description = "Allow DNS queries from DNS forwarder ${i}/32"
      stateless   = true
      protocol    = "17"
      src_type    = "CIDR_BLOCK"
      src         = "${i}/32"
      dst_port = {
        min = "53"
        max = "53"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ]
  )
  nsg_egress_rules_temp = concat([for i in var.inbound_query_cidrs :
    {
      description = "Allow DNS query responses to ${i}"
      stateless   = false
      protocol    = "17"
      dst_type    = "CIDR_BLOCK"
      dst         = i
      dst_port = {
        min = "53"
        max = "53"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ], [for i in local.dns_forwarder_ips :
    {
      description = "Allow DNS queries/query responses to DNS forwarder ${i}/32"
      stateless   = true
      protocol    = "17"
      dst_type    = "CIDR_BLOCK"
      dst         = "${i}/32"
      dst_port = {
        min = "53"
        max = "53"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ]
  )
  
  nsg_ingress_rules = var.allow_vcn_cidr == true ? concat(local.nsg_ingress_rules_temp, [ {
      description = "Allow DNS queries from VCN CIDR (${data.oci_core_vcn.this.cidr_block})"
      stateless   = true
      protocol    = "17"
      src_type    = "CIDR_BLOCK"
      src         = data.oci_core_vcn.this.cidr_block
      dst_port = {
        min = "53"
        max = "53"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    } ] ) : local.nsg_ingress_rules_temp
  nsg_egress_rules = var.allow_vcn_cidr == true ? concat(local.nsg_egress_rules_temp, [ {
      description = "Allow DNS query responses to VCN CIDR (${data.oci_core_vcn.this.cidr_block})"
      stateless   = true
      protocol    = "17"
      dst_type    = "CIDR_BLOCK"
      dst         = data.oci_core_vcn.this.cidr_block
      dst_port = {
        min = "53"
        max = "53"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    } ] ) : local.nsg_egress_rules_temp
  
  nsg_options_defaults = {
    name           = "dns"
    compartment_id = null
    defined_tags   = null
    freeform_tags  = null
  }
}

# resource definitions
resource "oci_core_network_security_group" "this" {
  compartment_id        = var.compartment_id
  vcn_id                = var.vcn_id
  display_name          = "hybrid_dns"
}

# ingress rules - hybrid DNS NSG
resource "oci_core_network_security_group_security_rule" "ingress_rules" {
  count                 = length(local.nsg_ingress_rules)
  depends_on            = [ oci_core_network_security_group.this ]

  network_security_group_id = oci_core_network_security_group.this.id
  direction             = "INGRESS"
  protocol              = local.nsg_ingress_rules[count.index].protocol
  description           = local.nsg_ingress_rules[count.index].description
  source                = local.nsg_ingress_rules[count.index].src
  source_type           = local.nsg_ingress_rules[count.index].src_type
  stateless             = local.nsg_ingress_rules[count.index].stateless

  udp_options {
    destination_port_range {
      min               = local.nsg_ingress_rules[count.index].dst_port.min
      max               = local.nsg_ingress_rules[count.index].dst_port.max
    }
  }
}

# egress rules - hybrid DNS NSG
resource "oci_core_network_security_group_security_rule" "egress_rules" {
  count                 = length(local.nsg_egress_rules)
  depends_on            = [ oci_core_network_security_group.this ]

  network_security_group_id = oci_core_network_security_group.this.id
  direction             = "EGRESS"
  protocol              = local.nsg_egress_rules[count.index].protocol
  description           = local.nsg_egress_rules[count.index].description
  destination           = local.nsg_egress_rules[count.index].dst
  destination_type      = local.nsg_egress_rules[count.index].dst_type
  stateless             = local.nsg_egress_rules[count.index].stateless

  udp_options {
    destination_port_range {
      min               = local.nsg_egress_rules[count.index].dst_port.min
      max               = local.nsg_egress_rules[count.index].dst_port.max
    }
  }
}

# ingress rules - existing NSGs to new NSG
resource "oci_core_network_security_group_security_rule" "ingress_rules_existing_to_new" {
  # for_each              = var.existing_nsg_ids != null ? var.existing_nsg_ids : null
  for_each              = toset(var.existing_nsg_ids)
  
  network_security_group_id = each.value
  direction             = "INGRESS"
  protocol              = "17"
  description           = "Permitting DNS query responses from hybrid DNS forwarders."
  source                = oci_core_network_security_group.this.id
  source_type           = "NETWORK_SECURITY_GROUP"
  stateless             = false

  udp_options {
    destination_port_range {
      min               = 53
      max               = 53
    }
  }
}

# egress rules - existing NSGs to new NSG
resource "oci_core_network_security_group_security_rule" "egress_rules_existing_to_new" {
  for_each              = toset(var.existing_nsg_ids)
  
  network_security_group_id = each.value
  direction             = "EGRESS"
  protocol              = "17"
  description           = "Permitting DNS queries to hybrid DNS forwarders."
  destination           = oci_core_network_security_group.this.id
  destination_type      = "NETWORK_SECURITY_GROUP"
  stateless             = true

  udp_options {
    destination_port_range {
      min               = 53
      max               = 53
    }
  }
}

# ingress rules - new NSG to existing NSGs
resource "oci_core_network_security_group_security_rule" "ingress_rules_new_to_existing" {
  # for_each              = var.existing_nsg_ids != null ? var.existing_nsg_ids : null
  for_each              = toset(var.existing_nsg_ids)
  
  network_security_group_id = oci_core_network_security_group.this.id
  direction             = "INGRESS"
  protocol              = "17"
  description           = "Permitting DNS query responses to hybrid DNS forwarders."
  source                = each.value
  source_type           = "NETWORK_SECURITY_GROUP"
  stateless             = false

  udp_options {
    destination_port_range {
      min               = 53
      max               = 53
    }
  }
}

# egress rules - new NSG to existing NSGs
resource "oci_core_network_security_group_security_rule" "egress_rules_new_to_existing" {
  for_each              = toset(var.existing_nsg_ids)
  
  network_security_group_id = oci_core_network_security_group.this.id
  direction             = "EGRESS"
  protocol              = "17"
  description           = "Permitting DNS queries from hybrid DNS forwarders."
  destination           = each.value
  destination_type      = "NETWORK_SECURITY_GROUP"
  stateless             = true

  udp_options {
    destination_port_range {
      min               = 53
      max               = 53
    }
  }
}
