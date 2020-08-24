#cloud-config

## Copyright © 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

write_files:
  # create dnsmasq config
  - path: /etc/dnsmasq.conf
    content: |
%{ for i in dns_mappings ~}
      server=/${i["domain_name"]}/${i["forwarder_ip"]}
%{ endfor ~}
%{ for i in rev_dns_mappings ~}
      rev-server=${ i["cidr"] },${ i["forwarder_ip"] }
%{ endfor ~}
      rev-server=${vcn_cidr},169.254.169.254
      cache-size=0

# packages:
#  - dnsmasq

runcmd:
  # Run firewall commands to open DNS (udp/53)
  - firewall-offline-cmd --zone=public --add-port=53/udp
  # install dnsmasq package
  - yum install dnsmasq -y
  # enable dnsmasq process
  - systemctl enable dnsmasq
  # restart dnsmasq process
  - systemctl restart dnsmasq
  # restart firewalld
  - systemctl restart firewalld
