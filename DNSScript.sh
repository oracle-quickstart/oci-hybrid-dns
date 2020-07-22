## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

write_files:
  # create dnsmasq config
  - path: /etc/dnsmasq.conf
    content: |
      server=/awesomedc.awesomecompany.local./192.168.0.1
      server=/awesomedc.awesomecompany.local./192.168.0.2
      rev-server=192.168.0.0/24,192.168.0.1
      rev-server=192.168.0.0/24,192.168.0.2
      rev-server=10.0.0.0/16,169.254.169.254
      cache-size=0


runcmd:
  # Run firewall commands to open DNS (udp/53)
  - sudo firewall-offline-cmd --zone=public --add-port=53/udp
  # install dnsmasq package
  - sudo yum update -y
  - sudo yum install dnsmasq -y
  # enable dnsmasq process
  - sudo systemctl enable dnsmasq
  # restart dnsmasq process
  - sudo systemctl restart dnsmasq
  # restart firewalld
  - sudo systemctl restart firewalld     
