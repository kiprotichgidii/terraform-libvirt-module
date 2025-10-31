#cloud-config
%{ if enable_dhcp }
version: 2
ethernets:
 alleths:
    match:
      name: "en*"
    dhcp4: true
%{ endif }

%{ if !enable_dhcp }
version: 2
ethernets:
  ${nic}:
    dhcp4: no
    addresses: [${ip_address}]
    gateway4: ${gateway}
    nameservers:
       addresses:
       %{~ for dns in dns_servers ~}
       - ${dns}
       %{~ endfor ~}
%{ endif }