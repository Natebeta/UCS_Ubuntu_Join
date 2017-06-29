# Set some environment variables
. /etc/univention/ucr_master

# Install required packages
DEBIAN_FRONTEND=noninteractive apt-get install -y heimdal-clients

# Default krb5.conf
cat >/etc/krb5.conf <<__EOF__
[libdefaults]
    default_realm = $kerberos_realm
    kdc_timesync = 1
    ccache_type = 4
    forwardable = true
    proxiable = true

[realms]
$kerberos_realm = {
   kdc = $master_ip $ldap_master
   admin_server = $master_ip $ldap_master
}
__EOF__

# Stop and disable the avahi daemon
systemctl stop avahi-daemon.service
sed -i 's|start on (|start on (never and |' /etc/init/avahi-daemon.conf

# Synchronize the time with the UCS system
apt-get install -y ntpdate
ntpdate -bu $ldap_master

# Test Kerberos
kinit Administrator

# Requires domain password
rsh Administrator@$ldap_master ls /etc/univention

# Destroy the kerberos ticket
kdestroy
