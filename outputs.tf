## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "dns_forwarder_private_ips" {
  value = flatten(concat(oci_core_instance.this.*.private_ip))
}
