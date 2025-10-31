#cloud-config
version: 2
ethernets:
%{ if enable_dhcp }
  alleths:
    match:
      name: "en*"
    dhcp4: true
%{ else }
  ${nic}:
    dhcp4: no
    addresses: [${ip_address}]
    gateway4: ${gateway}
    nameservers:
      addresses:
%{ for dns in dns_servers ~}
        - ${dns}
%{ endfor ~}
%{ endif }