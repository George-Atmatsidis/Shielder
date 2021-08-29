#!/usr/bin/env bash

SecureSsh(){
echo "Hello,$USER,
Because we connect to the server via ssh root which means that a third party can also access our server as root.
So anyone with a bruteforce method can try a combination of passwords to gain access and perform malicious actions.
One action we can take is to lock ssh root and create a new system user with sudo privileges.
Give new username in the empty space below
[IMPORTANT]: Use strong username/passcode for SSH"

read newuser
sudo adduser $newuser
sudo passwd $newuser
sudo usermod -aG sudo $newuser
echo "[*] Adding user $newuser to ssh"
sudo bash -c "echo 'AllowUsers $newuser' >> /etc/ssh/sshd_config"
##################################
echo "[*] Removing root login from ssh"
sudo sed -i 's/\(#PermitRootLogin prohibit-password\).*/\PermitRootLogin no/' /etc/ssh/sshd_config
####################################
echo "[*] Disable tunneled clear text passwords"
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
#####################################
echo "Open from your LocalMachine terminal(CLI) and copy paste the following command:
ssh-keygen && cd ~/.ssh/ && ssh-copy-id -i ./id_rsa.pub $newuser@$(curl ifconfig.me) && cd ~"
read -p "When you have done please hit Enter"
#####################################
echo "[*] Restart SSH Service"
sudo systemctl restart ssh
}


#functions calls

if [[ $USER -eq "user" || $USER -eq "root" ]]; then
  SecureSsh
fi
