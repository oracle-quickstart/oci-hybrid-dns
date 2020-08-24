## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

provider "oci" {
  tenancy_ocid = var.tenancy_id
  user_ocid = var.user_id
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
  version = ">= 3.27.0"
}