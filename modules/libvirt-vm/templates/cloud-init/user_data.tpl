#cloud-config
timezone: ${timezone}

# Hostname management
preserve_hostname: ${preserve_hostname}
manage_etc_hosts: ${manage_etc_hosts}
ssh_pwauth: ${enable_ssh_password_auth}
disable_root: ${disable_ssh_root_login}

# User Management
users:
  - name: ${user_name}
    gecos: ${user_fullname}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: ${lock_user_password}
    shell: ${user_shell}
    ssh_authorized_keys:
    %{~ for ssh_key in authorized_keys ~}
      - ${ssh_key}
    %{~ endfor ~}
    groups: sudo
    home: /home/${user_name}
    manage_home: true
  - name: root
    gecos: root
    lock_passwd: ${lock_root_user_password}
    shell: /bin/bash
    ssh_authorized_keys:
    %{~ for ssh_key in authorized_keys ~}
      - ${ssh_key }
    %{~ endfor ~}

# Set User Password
chpasswd:
  expire: false
  users:
  %{~ if set_user_password ~}
    - name: ${user_name}
      password: ${user_password}
      type: crypted
  %{~ endif ~}
  %{~ if set_root_password ~}
    - name: root
      password: ${root_password}
      type: crypted
  %{~ endif ~}

# Grow the root partition to fill the disk
growpart:
  mode: auto
  devices: ['/']
resize_rootfs: true

# Package Management
package_update: ${package_update}
package_upgrade: ${package_upgrade}

# Install Additional Packages
%{ if length(packages) > 0 ~}
packages:
  %{~ for package in packages ~}
  - ${package}
  %{~ endfor ~}
%{ endif ~}

# First Boot Commands to be executed only once
%{ if length(runcmds) > 0 ~}
runcmd:
  %{~ for cmd in runcmds ~}
  - ${cmd}
  %{~ endfor ~}
%{ endif ~}

%{ if disable_ipv6 ~}
# Disable IPv6 if specified
write_files:
  - path: /etc/sysctl.d/99-disable-ipv6.conf
    permissions: '0644'
    owner: root:root
    content: |
      net.ipv6.conf.all.disable_ipv6 = 1
      net.ipv6.conf.default.disable_ipv6 = 1
      net.ipv6.conf.lo.disable_ipv6 = 1
%{ endif ~}