# oci-hybrid-DNS

A hybrid DNS is an overlay deployment of DNS forwarders that are configured to “route” DNS resolution requests between different private DNS namespaces (such as the internal OCI VCN DNS and what is commonly used in many private data centers).

## Terraform Provider for Oracle Cloud Infrastructure
The OCI Terraform Provider is now available for automatic download through the Terraform Provider Registry. 
For more information on how to get started view the [documentation](https://www.terraform.io/docs/providers/oci/index.html) 
and [setup guide](https://www.terraform.io/docs/providers/oci/guides/version-3-upgrade.html).

* [Documentation](https://www.terraform.io/docs/providers/oci/index.html)
* [OCI forums](https://cloudcustomerconnect.oracle.com/resources/9c8fa8f96f/summary)
* [Github issues](https://github.com/terraform-providers/terraform-provider-oci/issues)
* [Troubleshooting](https://www.terraform.io/docs/providers/oci/guides/guides/troubleshooting.html)

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-hybrid-dns
    cd oci-hybrid-dns
    ls

## Prerequisites
1- You  need to do some pre-deploy setup. That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

2- Modify `terraform.tfvars` file and populate with the following information:
```
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

ssh_public_key  = "<public_ssh_key_path>"

region = "<oci_region>"

compartment_ocid = "<compartment_ocid>"
```

3- DNSScrpt.sh file deploys dnsmasq on the DNS forwarding hosts and can be left as is

4- `variable.tf`, `vcn.tf`, and `dns.tf`  files has some default values set which can be modified per the deployment requirement

## Deploy:

    terraform init
    terraform plan
    terraform apply

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    terraform destroy

## adb-ml-architecture

![](./images/adb-ml.PNG)


## Reference Architecture

- [Set up a data science environment that uses Oracle Machine Learning](https://docs.oracle.com/en/solutions/data-science-environment/index.html)
- [Creating Applications with APEX in Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/application-express-autonomous-database.html)