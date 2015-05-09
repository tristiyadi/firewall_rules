#!/bin/bash
IPT=/sbin/iptables
$IPT - F             #flushes the previously defined script
#write the policies now
$IPT -P OUTPUT ACCEPT # allow the output
$IPT -P INPUT DROP    #Default policy for the input chain is drop
$IPT -P FORWARD DROP  #Default policy for the forward chain is also drop

#allowed inputs
#$IPT -A INPUT --in-interface lo -j ACCEPT
$IPT -A INPUT -j ACCEPT -p tcp --dport 80
$IPT -A INPUT -j ACCEPT -p tcp --dport 443

#Allow established sessions
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Anti-spoofing
#$IPT -A INPUT --in-interface!lo --source 127.0.0.0/8 -j DROP
#Blocking spoofed Addresses
$IPT -A INPUT -i external_interface -s 192.168.100.0/24 -j REJECT

#Limit Ping Requests
$IPT -A INPUT -p icmp -m icmp -m limit -limit 1/second -j ACCEPT

# Drop all invalid packets
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A OUTPUT -m state --state INVALID -j DROP

# Stop smurf attacks
$IPT -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
$IPT -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
$IPT -A INPUT -p icmp -m icmp -j DROP

# Drop excessive RST packets to avoid smurf attacks
$IPT -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Preventing Pings
$IPT -A INPUT -p icmp --icmp-type echo-request -j DROP
