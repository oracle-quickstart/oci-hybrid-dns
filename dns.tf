## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


variable "instance_image_ocid" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"

      us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaasc56hnpnx7swoyd2fw5gyvbn3kcdmqc2guiiuvnztl2erth62xnq"
      us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaxrqeombwty6jyqgk3fraczdd63bv66xgfsqka4ktr7c57awr3p5a"
      eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaayxmzu6n5hsntq4wlffpb4h6qh6z3uskpbm5v3v4egqlqvwicfbyq"

  }
}

resource "oci_core_instance" "DnsVM" {
  availability_domain = "${data.oci_identity_availability_domain.ad1.name}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DnsVM"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id = "${oci_core_subnet.MgmtSubnet.id}"
  }

metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
    user_data = "${base64encode(file("DNSScript.sh"))}"
  
  }


  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  timeouts {
    create = "10m"
  }
}

resource "oci_core_instance" "DnsVM2" {
  availability_domain = "${data.oci_identity_availability_domain.ad2.name}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DnsVM2"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id = "${oci_core_subnet.MgmtSubnet2.id}"
  }

metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
    user_data = "${base64encode(file("DNSScript.sh"))}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  timeouts {
    create = "10m"
  }
}

# Gets a list of VNIC attachments on the DNS instance
data "oci_core_vnic_attachments" "DnsVMVnics" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${data.oci_identity_availability_domain.ad1.name}"
  instance_id         = "${oci_core_instance.DnsVM.id}"
}

data "oci_core_vnic_attachments" "DnsVMVnics2" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${data.oci_identity_availability_domain.ad2.name}"
  instance_id         = "${oci_core_instance.DnsVM2.id}"
}

# Gets the OCID of the first (default) vNIC
data "oci_core_vnic" "DnsVMVnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.DnsVMVnics.vnic_attachments[0],"vnic_id")}"
}

data "oci_core_vnic" "DnsVMVnic2" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.DnsVMVnics2.vnic_attachments[0],"vnic_id")}"
}

# Update the default DHCP options to use custom DNS servers
resource "oci_core_default_dhcp_options" "default-dhcp-options" {
  manage_default_resource_id = "${oci_core_virtual_network.CoreVCN.default_dhcp_options_id}"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "CustomDnsServer"

    custom_dns_servers = ["${data.oci_core_vnic.DnsVMVnic.private_ip_address}",
      "${data.oci_core_vnic.DnsVMVnic2.private_ip_address}",
    ]
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["${oci_core_virtual_network.CoreVCN.dns_label}.oraclevcn.com"]
  }
}

output "DnsServer1" {
  value = ["${data.oci_core_vnic.DnsVMVnic.private_ip_address}"]
}

output "DnsServer2" {
  value = ["${data.oci_core_vnic.DnsVMVnic2.private_ip_address}"]
}

data "template_file" "generate_named_conf" {
  template = "${file("named.conf.tpl")}"

  vars = {
    vcn_cidr           = "${var.vcn_cidr}"
    onprem_cidr        = "${var.onprem_cidr}"
    onprem_dns_zone    = "${var.onprem_dns_zone}"
    onprem_dns_server1 = "${var.onprem_dns_server1}"
    onprem_dns_server2 = "${var.onprem_dns_server2}"
  }
}

resource "null_resource" "configure-bind-vm1" {
  connection {
    type        = "ssh"
    user        = "opc"
   # private_key = "~/.ssh/id_rsa.pub"
   #private_key = "${var.ssh_private_key}"
   private_key = chomp(file(var.ssh_private_key))
    host        = "${data.oci_core_vnic.DnsVMVnic.public_ip_address}"
    timeout     = "30m"
  }

  provisioner "file" {
    content     = "${data.template_file.generate_named_conf.rendered}"
    destination = "~/named.conf"
  }

}

resource "null_resource" "configure-bind-vm2" {
  connection {
    type        = "ssh"
    user        = "opc"
  private_key = chomp(file(var.ssh_private_key))
  #  private_key = "${var.ssh_private_key}"
    host        = "${data.oci_core_vnic.DnsVMVnic2.public_ip_address}"
    timeout     = "30m"
  }

  provisioner "file" {
    content     = "${data.template_file.generate_named_conf.rendered}"
    destination = "~/named.conf"
  }

}
