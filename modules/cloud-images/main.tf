locals {
  os = {
    "ubuntu" = {
      "latest" = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img",
      "24.04"  = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img",
      "22.04"  = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img",
      "20.04"  = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img",
      "18.04"  = "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img",
      "16.04"  = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
    },
    "rockylinux" = {
      "latest"   = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2",
      "10"       = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2",
      "9"        = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2",
      "8"        = "https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2"
    },
    "almalinux" = {
      "latest"   = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2",
      "10"       = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2",
      "9"        = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2",
      "8"        = "https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
    },
    "oraclelinux" = {
      "latest"   = "https://yum.oracle.com/templates/OracleLinux/OL10/u0/x86_64/OL10U0_x86_64-kvm-b266.qcow2",
      "10"       = "https://yum.oracle.com/templates/OracleLinux/OL10/u0/x86_64/OL10U0_x86_64-kvm-b266.qcow2",
      "9"        = "https://yum.oracle.com/templates/OracleLinux/OL9/u5/x86_64/OL9U5_x86_64-kvm-b253.qcow2",
      "8"        = "https://yum.oracle.com/templates/OracleLinux/OL8/u10/x86_64/OL8U10_x86_64-kvm-b237.qcow2"
    },
    "centos-stream" = {
      "latest"   = "https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2",
      "10"       = "https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2",
      "9"        = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
    },
    "debian" = {
      "latest"    = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2",
      "13"        = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2",
      "12"        = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2",
      "11"        = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2",
      "10"        = "https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2"
    },
    "fedora" = {
      "latest"   = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-42-1.1.x86_64.qcow2",
      "42"       = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-42-1.1.x86_64.qcow2",
      "41"       = "https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
    },
    "alpine" = {
      "latest"   = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/cloud/generic_alpine-3.21.2-x86_64-bios-tiny-r0.qcow2",
      "3.21"     = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/cloud/generic_alpine-3.21.2-x86_64-bios-tiny-r0.qcow2",
      "3.20"     = "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/cloud/nocloud_alpine-3.20.5-x86_64-bios-tiny-r0.qcow2"
    },
    "amazonlinux" = {
      "latest"   = "https://cdn.amazonlinux.com/al2023/os-images/2023.7.20250512.0/kvm/al2023-kvm-2023.7.20250512.0-kernel-6.1-x86_64.xfs.gpt.qcow2",
      "2023"     = "https://cdn.amazonlinux.com/al2023/os-images/2023.7.20250512.0/kvm/al2023-kvm-2023.7.20250512.0-kernel-6.1-x86_64.xfs.gpt.qcow2"
    },
    "opensuse" = {
      "latest"   = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.6/images/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2",
      "15.6"     = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.6/images/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2",
      "15.5"     = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.5/images/openSUSE-Leap-15.5.x86_64-NoCloud.qcow2"
    },
    "archlinux" = {
      "latest"   = "https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
    },
    "freebsd" = {
      "latest"   = "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.2/2024-12-08/ufs/freebsd-14.2-ufs-2024-12-08.qcow2",
      "14"       = "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.2/2024-12-08/ufs/freebsd-14.2-ufs-2024-12-08.qcow2",
      "13"       = "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/13.4/2024-10-28/ufs/freebsd-13.4-ufs-2024-10-28.qcow2"
    }
  }
}