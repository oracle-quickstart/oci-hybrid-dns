# OCI Hybrid DNS Solution

## Introduction

This stack is designed to deploy a hybrid DNS solution in an existing VCN.  The goal is to allow for name resolution (largely targeting private DNS name spaces) between an OCI VCN and another environment (non-OCI and/or a separate OCI VCN).

Other solutions exist, such as those built as a module.  This solution is designed to work standalone, without the complexity (and overhead) of a Terraform module, as well as support local and OCI Resource Manager (ORM) deployments.

## Purpose

Deploy 1+ DNS forwarders (using dnsmasq) and the necessary infrastructure (OCI Subnet, OCI NSG rules, etc.) to leverage such forwarders in OCI.

## Intended Audience

This is designed for use by anyone who needs this functionality.  Because it's designed for use in ORM, care has been taken to expose a minimalistic interface, designed to address many (but not necessarily all) hybrid DNS use-cases.  Because it's raw Terraform (not even a module), it might be easily extended (customized) to support additional use-cases.

## How to Use

Usage is pretty straight forward:

1. Clone this repo.
2. Create your own `terraform.tfvars` file (feel free to use `terraform.tfvars.template` or `terraform.tfvars.example` as your starting point).
3. Run `terraform init`.
4. Run `terraform plan`.
5. Review proposed changes (shown in plan).  Make changes as-needed or if no changes required, proceed.
6. Once proposed changes have been reviewed and are correct, run `terraform apply`.
7. Configure the non-OCI forwarder(s) (along with any needed infrastructure changes) to use the new DNS forwarders that might have been deployed in OCI.

### Example

A sample scenario is given in the `terraform.tfvars.example` file, which lists some fictitious CIDRs (still requiring a lot of changes as the OCIDs, region, etc. will be different from your environment).

## Detailed Description

### Pre-Existing (Required) Resources

It's required that a VCN be present, as well as any necessary connectivity to the other non-OCI (or non-VCN) forwarders.  This means that any DRG or other kind of gateway(s) be present, along with a Route Table that has the appropriate route table rules to route traffic appropriately.  It's also assumed that the desired compartment to use be present prior to deployment.

### Deployed Resources

This solution might deploy:

#### DHCP Options

Two DHCP Options are created: `vcn_dns` and `hybrid_dns`.  The `vcn_dns` DHCP Option is used by the hybrid DNS Subnet, pointing to the built-in VCN/Internet Resolver.  The `hybrid_dns` DHCP Option may be used on your Subnets that you want to utilize the hybrid DNS forwarders, pointing to the forwarder IPs as the custom resolvers to use for name resolution (as well as using the VCN private DNS namespace as its search space).

#### Subnet

One subnet is created as a part of this solution, which is where the hybrid DNS forwarders are deployed.  This subnet uses the `vcn_dns` DHCP Options as well as requires a valid (pre-existing) Route Table that has rules for connectivity to the other (non-OCI) DNS forwarders.

#### NSG and NSG Rules

One NSG (`hybrid_dns`) is created as a part of this solution, which is used for the hybrid DNS forwarder vNICs.  Rules permitting UDP/53 (DNS requests and responses) are configured as follows:

* If the `allow_vcn_cidr` variable is set to true, the VCN CIDR will be added ingress/egress for DNS queries/reponses to the `hybrid_dns` NSG.
* All CIDRs in the `inbound_query_cidrs` variable list are added as ingress/egress for DNS queries/responses to the `hybrid_dns` NSG.
* All `forwarder_ip` variables (specified in the `dns_forwarding_rules` and `reverse_dns_mappings` variables) are added as ingress/egress for DNS queries/responses to the `hybrid_dns` NSG.

If the `existing_nsg_ids` variable list is populated with NSG OCIDs, NSG rules will be added to each to permit DNS queries/reponses to/from the newly-created DNS forwarder NSG (and vice-versa).  It's assumed that since the VCN is existing, there will be the need to permit traffic to/from existing NSGs, which is what this setting allows for.

#### Compute Instances

One or more compute instances are created and configured with dnsmasq, which act as the DNS forwarders in the solution.

Here are the variables that impact the DNS forwarder instance configuration:

| Variable | Valid Values | Description |
|----------|--------------|-------------|
| `default_ssh_auth_keys` | List of full paths to SSH public keys. | The public keys to be used for SSH access to the compute instances created. |
| `default_img_name` | A string containing a valid image name. | See [https://docs.cloud.oracle.com/en-us/iaas/images/](https://docs.cloud.oracle.com/en-us/iaas/images/) for the current list of images (names, info, etc.). |
| `instance_shape` | A string containing a valid shape. | See [https://docs.cloud.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm](https://docs.cloud.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm) for the current list of OCI compute instance shapes. |
| `dns_forwarding_rules` | A list of maps, with each entry providing a DNS domain name (namespace) and forwarder IP. | This is used to configure forwarding rules in dnsmasq. |
| `reverse_dns_mappings` | A list of maps with each entry providing a CIDR (for reverse DNS lookups) and forwarder IP. | This is also used in the configuration of dnsmasq, but for reverse lookups. |
| `num_forwarders` | 1, 2 or 3. | How many hybrid DNS forwarders should be deployed. |

## Variables

Many of the variables are described above in this document (for the different resources).  For a more verbose and complete reference, please look at `variables.tf`.  Care has been taken to provide a description and structure for each variable used.

## Contributing

This project is open source. Oracle appreciates any contributions that are made by the open source community.

## License

Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.

Licensed under the Universal Permissive License 1.0 or Apache License 2.0.

See [LICENSE](LICENSE) for more details.
