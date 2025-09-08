iptables -F -t filter
iptables -F -t nat
iptables -F -t mangle
iptables -X -t filter
iptables -X -t nat
iptables -X -t mangle

#Set policy
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

#Group rules into chains
iptables -N _INPUT
iptables -N _OUTPUT
iptables -N _FORWARD
iptables -N _POSTROUTING -t nat

#Append chains
iptables -A INPUT -j _INPUT
iptables -A OUTPUT -j _OUTPUT
iptables -A FORWARD -j _FORWARD
iptables -A POSTROUTING -t nat -j _POSTROUTING

#Allow related and established connections
iptables -A _INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A _FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

#Allow loopback
iptables -A _INPUT -i lo -j ACCEPT

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
