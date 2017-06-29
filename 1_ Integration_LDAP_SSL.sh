#Set the IP address of the UCS DC Master, 192.168.0.3 in this example
export MASTER_IP=172.16.5.176

mkdir /etc/univention
ssh root@${MASTER_IP} ucr shell | 
 grep -v ^hostname= >/etc/univention/ucr_master
echo "master_ip=${MASTER_IP}" >>/etc/univention/ucr_master
chmod 660 /etc/univention/ucr_master
. /etc/univention/ucr_master

echo "${MASTER_IP} ${ldap_master}" >>/etc/hosts

# Set some environment variables
. /etc/univention/ucr_master

# Download the SSL certificate
mkdir -p /etc/univention/ssl/ucsCA/
wget -O /etc/univention/ssl/ucsCA/CAcert.pem \
    http://${ldap_master}/ucs-root-ca.crt

# Create an account and save the password
password="$(tr -dc A-Za-z0-9_ </dev/urandom | head -c20)"
if [ "$version_version" = 3.0 ] && [ "$version_patchlevel" -lt 2 ]
then
    ssh root@${ldap_master} udm computers/managedclient create \
        --position "cn=computers,${ldap_base}" \
        --set name=$(hostname) --set password="${password}"
else
    ssh root@${ldap_master} udm computers/ubuntu create \
        --position "cn=computers,${ldap_base}" \
        --set name=$(hostname) --set password="${password}" \
        --set operatingSystem="$(lsb_release -is)" \
        --set operatingSystemVersion="$(lsb_release -rs)"
fi
printf '%s' "$password" >/etc/ldap.secret
chmod 0400 /etc/ldap.secret

# Create ldap.conf
cat >/etc/ldap/ldap.conf <<__EOF__
TLS_CACERT /etc/univention/ssl/ucsCA/CAcert.pem
URI ldap://$ldap_master:7389
BASE $ldap_base
__EOF__
