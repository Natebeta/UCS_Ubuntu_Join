cat >/usr/share/pam-configs/ucs_mkhomedir <<__EOF__
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
    required    pam_mkhomedir.so umask=0022 skel=/etc/skel
__EOF__

DEBIAN_FRONTEND=noninteractive pam-auth-update

echo '*;*;*;Al0000-2400;audio,cdrom,dialout,floppy,plugdev,adm' \
   >>/etc/security/group.conf

cat >>/usr/share/pam-configs/local_groups <<__EOF__
Name: activate /etc/security/group.conf
Default: yes
Priority: 900
Auth-Type: Primary
Auth:
    required    pam_group.so use_first_pass
__EOF__

DEBIAN_FRONTEND=noninteractive pam-auth-update


# Add a field for a user name, disable user selection at the login screen
mkdir -p /etc/lightdm/lightdm.conf.d
cat >>/etc/lightdm/lightdm.conf.d/99-show-manual-userlogin.conf <<__EOF__
[SeatDefaults]
greeter-show-manual-login=true
greeter-hide-users=true
__EOF__
