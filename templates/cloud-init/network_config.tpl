#cloud-config
version: 2
ethernets:
  ${nic}:
    dhcp4: ${enable_dhcp}
%{ if !enable_dhcp }
    addresses: [${ip_address}]
    gateway4: ${gateway}
    nameservers:
      addresses: [${dns}]
%{ endif }