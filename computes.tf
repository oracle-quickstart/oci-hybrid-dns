## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  #Transform the list of images in a tuple
  list_images       = { for s in data.oci_core_images.this.images : 
                          s.display_name => 
                            { id               = s.id, 
                              operating_system = s.operating_system
                            } }
  
  # Image list by key to take the OS
  list_images_key   = { for s in data.oci_core_images.this.images : 
                          s.id =>
                            { id               = s.id,
                              operating_system = s.operating_system
                            } }
  
  num_ads = length(data.oci_identity_availability_domains.this.availability_domains)
  num_fds = { for i in range(local.num_ads):
                i => length(data.oci_identity_fault_domains.this[i])
  }
}

resource "oci_core_instance" "this" {
  count = var.num_forwarders == null ? 0 : var.num_forwarders
  availability_domain       = data.oci_identity_availability_domains.this.availability_domains[count.index % local.num_ads].name
  compartment_id            = var.compartment_id
  shape                     = var.instance_shape
  
  create_vnic_details {
    subnet_id               = oci_core_subnet.this.id
    assign_public_ip        = false
    display_name            = "dns_forwarder_${count.index+1}"
    nsg_ids                 = [ oci_core_network_security_group.this.id ]
  }
  
  display_name              = "dns_forwarder_${count.index+1}"
  fault_domain              = data.oci_identity_fault_domains.this[count.index % local.num_ads].fault_domains[count.index % local.num_fds[count.index % local.num_ads]].name
  hostname_label            = "dns${count.index+1}"
  
  metadata = {
    ssh_authorized_keys     = join("\n", [for s in var.default_ssh_auth_keys : chomp(file(s))])
    user_data               = base64encode(templatefile("${path.root}/dns.tpl", {
      dns_mappings     = var.dns_forwarding_rules != null ? var.dns_forwarding_rules : []
      rev_dns_mappings = var.reverse_dns_mappings != null ? var.reverse_dns_mappings : []
      vcn_cidr         = data.oci_core_vcn.this.cidr_block
    }))
  }
  
  source_details {
    source_id               = local.list_images[var.default_img_name].id
    source_type             = "image"
  }
}