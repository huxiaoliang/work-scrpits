#!/bin/bash
#BY MRCO,2015-06-10
#MODIFY 2015-06-10
#ping all on line vms in this subnet to trace carp 
#subnet=`route -n|grep "UG" |awk '{print $2}'|sed 's/..$//g'`
subnet="192.168.122"
for ip in $subnet.{1..253};do
{
        ping -c1 $ip >/dev/null 2>&1
}&
done
subnet="9.111.250"
for ip in $subnet.{1..253};do
{
            ping -c1 $ip >/dev/null 2>&1
}&
done


running_vms=`virsh list |grep running`
echo -ne " total `echo "$running_vms"|wc -l` vms is running.\n"
for i in `echo "$running_vms" | awk '{ print $2 }'`;do
  mac=`virsh dumpxml $i |grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"`
  ips=""
  for mc in $mac;do
     ip=`arp -ne |grep "$mc" |awk '{printf $1}'`
     ips="$ips"" ""$ip"
  done
printf "%-30s %-30s\n" $i "$ips"
done
