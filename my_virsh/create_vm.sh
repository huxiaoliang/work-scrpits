#!/bin/bash

base_img_path=/var/lib/libvirt/images/centos7u2.img
vm_img_dir=/var/lib/libvirt/images/
proxy_host="9.21.49.147"
proxy_port=8118

function post_config() {
  echo "post config ..."
  # to resove vi/vim auto indent issuse by copy
  # from external
  rm -rf /mnt/root/.vimrc
}

function set_proxy() {
  # set yum http proxy
  \cp /etc/yum.repos.d/local.repo /mnt/etc/yum.repos.d/  
  echo "proxy=http://$proxy_host:$proxy_port" >> /mnt/etc/yum.conf
  # set docker http proxy
  mkdir -p /mnt/etc/systemd/system/docker.service.d/
(
cat << EOF
[Service]
Environment="HTTPS_PROXY=https://$proxy_host:$proxy_port" "HTTP_PROXY=http://$proxy_host:$proxy_port" "NO_PROXY=localhost,127.0.0.1"
EOF
 ) > /mnt/etc/systemd/system/docker.service.d/http-proxy.conf
}


function get_public_ip() {
	while true
		random=$(($RANDOM%255))
		do
		 if [ "$random" == "0" -o "$random" == "1" -o "$random" == "2" ];then
		   continue
		 fi
		 ping -c1 9.111.250.$random >/dev/null 2>&1
		 if [ "$?" == "1" ]; then
		   break
		 fi
		done
		echo "9.111.250.$random"
}

function set_public_ip() {
(
cat << EOF
DEVICE=ens3
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=$1
NETMASK=255.255.255.0
GATEWAY=9.111.250.2
DNS1=9.111.248.111
DNS2=9.111.248.112
EOF
) > /mnt/etc/sysconfig/network-scripts/ifcfg-ens3
}


function set_hostname() {
  echo "NETWORKING=yes">/mnt/etc/sysconfig/network
  echo "HOSTNAME=$1">>/mnt/etc/sysconfig/network
  echo "$1">/mnt/etc/hostname
}

function install_vm() {
  hostname=$1
  qemu-img create -f qcow2 -b $base_img_path $vm_img_dir/$hostname.img
  guestmount -i -w -a $vm_img_dir/$hostname.img /mnt
  public_ip=`get_public_ip`
  set_public_ip $public_ip
  set_hostname $hostname
  set_proxy
  post_config
  umount /mnt
  virt-install --import --name=$hostname --vcpus=8 --ram 8192 --boot hd --disk path=$vm_img_dir/$hostname.img,format=qcow2,bus=virtio --network bridge=br0 --autostart --graphics vnc,keymap=en-us --noautoconsole
}


for domain_name in $@; do
    install_vm $domain_name
done
