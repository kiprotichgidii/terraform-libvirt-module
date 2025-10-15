version: 2
ethernets:
  ${nic}:
    dhcp4: ${enable_dhcp}
%{ if !enable_dhcp }
    addresses: [${ip_address}/24]
    gateway4: ${gateway}
    nameservers:
      addresses: [${dns}]
%{ endif }