#!/bin/bash
domain_name=$1
vm_img_dir=/var/lib/libvirt/images/

for domain_name in $@; do
  path=$vm_img_dir/$domain_name.img
  virsh destroy $domain_name
  virsh undefine $domain_name
  rm -rf $path
  echo $domain_name
  sed -i '/'"$domain_name"'/d'  /etc/hosts
done

