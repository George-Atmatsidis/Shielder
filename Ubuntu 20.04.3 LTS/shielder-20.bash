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
sudo usermod -aG sudo $newuser
echo "[*] Adding user $newuser to ssh"
sudo bash -c "echo 'AllowUsers $newuser' >> /etc/ssh/sshd_config"
##################################
echo "[*] Set idle time to 1minute"
sudo sed -i 's/\(#ClientAliveInterval 0\).*/\ClientAliveInterval 1m/' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 0/' /etc/ssh/sshd_config
##################################
echo "[*] Disable Empty Passwords from ssh passcode connection's"
sudo sed -i 's/\(#PermitEmptyPasswords no\).*/\PermitEmptyPasswords no/' /etc/ssh/sshd_config
echo "[*] Removing root login from ssh"
sudo sed -i 's/\(#PermitRootLogin prohibit-password\).*/\PermitRootLogin no/' /etc/ssh/sshd_config
####################################
echo "[*] Disable Forwarding"
sudo sed -i 's/\(X11Forwarding yes\).*/\X11Forwarding no/' /etc/ssh/sshd_config
sudo sed -i 's/\(#AllowTcpForwarding yes\).*/\AllowTcpForwarding no/' /etc/ssh/sshd_config
##################################
echo "[*] Set maxauth trie's to 2"
sudo sed -i 's/\(#MaxAuthTries 6\).*/\MaxAuthTries 2/' /etc/ssh/sshd_config
##################################
echo "[*] Set A Login Grace Timeout"
sudo sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/' /etc/ssh/sshd_config
##################################
echo "[*] Disable .Rhosts"
sudo sed -i 's/#IgnoreRhosts yes/IgnoreRhosts yes/' /etc/ssh/sshd_config
##################################
echo "[*] Disable Host-Based Authentication"
sudo sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#IgnoreUserKnownHosts no/IgnoreUserKnownHosts yes/' /etc/ssh/sshd_config
##################################
echo "[*] Log More Information ssh log file"
sudo sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
##################################
echo "[*] How many parallel ssh connections you want to allow?"
read maxstartups
while (("$maxstartups" <= 0))
do
  echo "You cant use 0 or negative value.Give value > 0"
  read maxstartups
done
sudo sed -i 's/\(#MaxStartups 10:30:100\).*/\MaxStartups '$maxstartups'/' /etc/ssh/sshd_config
##################################
echo "[*] Displaying the last login"
sudo sed -i 's/#PrintLastLog yes/PrintLastLog yes/' /etc/ssh/sshd_config
##################################
echo "[*] Check User Specific Configuration Files"
sudo sed -i 's/#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
##################################
echo "[*] Prevent Privilege Escalation"
sudo bash -c "echo 'UsePrivilegeSeparation sandbox' >> /etc/ssh/sshd_config"
##################################
echo "[*] Disable GSSAPI Authentication"
sudo sed -i 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/' /etc/ssh/sshd_config
##################
echo "[*] Disable Kerberos Authentication"
sudo sed -i 's/#KerberosAuthentication no/KerberosAuthentication no/' /etc/ssh/sshd_config
##################
#echo "[*] Use FIPS 140-2"
#sudo sed -i 's/#RekeyLimit default none/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/' /etc/ssh/sshd_config
####################################
echo "[*] Disable tunneled clear text passwords"
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
#echo "Open from your LocalMachine terminal(CLI) and copy paste the following command:
#ssh-keygen && cd ~/.ssh/ && ssh-copy-id -i ./id_rsa.pub $newuser@$(curl ifconfig.me) && cd ~"
#read -p "When you have done please hit Enter"
#####################################
echo "[*] Restart SSH Service"
sudo systemctl restart ssh
}

GoogleTwoFa(){
  echo "[*] Installing the Google Authenticator PAM module"
  sudo apt install -y libpam-google-authenticator
  echo "[*] Configuring SSH - To make SSH use the Google Authenticator PAM module,the following line added to the /etc/pam.d/sshd file:"
  sudo bash -c "echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd >>"
  echo "[*] Restart the sshd daemon"
  sudo systemctl restart sshd.service
  echo "[*] Modify /etc/ssh/sshd_config ??? change ChallengeResponseAuthentication from no to yes"
  sudo sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
  echo "[*] Installing Google 2FA for $newuser"
  su $newuser -c google-authenticator

}
#functions calls

if [[ $USER -eq "user" || $USER -eq "root" ]]; then
  SecureSsh
fi
GoogleTwoFa
