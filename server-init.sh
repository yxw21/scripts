echo New username:
read user
echo New username password:
read password
echo SSH public key:
read publickey
echo ROOT password
read rootpassword
# Add user
useradd -m -s /bin/bash $user
# User directory configuration
chmod 700 /home/$user
mkdir /home/$user/.ssh
chown -R $user:$user /home/$user/.ssh
chmod 700 /home/$user/.ssh
echo $publickey > /home/$user/.ssh/authorized_keys
chown -R $user:$user /home/$user/.ssh/authorized_keys
chmod 600 /home/$user/.ssh/authorized_keys
# Set the new user password
echo $user:$password | chpasswd
# Update root password
echo root:$rootpassword | chpasswd
# SSH publickey login
sed -i 's/#PubkeyAuthentication\syes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
# SSH forbids password login
sed -i 's/PasswordAuthentication\syes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# SSH forbids root login
sed -i 's/PermitRootLogin\syes/PermitRootLogin no/g' /etc/ssh/sshd_config
# Restart ssh
systemctl restart sshd
# Allow new user to use sudo
sed -i 44a"$user  ALL=(ALL:ALL) ALL" /etc/sudoers
# Ensure that the systemd-resolved service is running
systemctl is-active --quiet systemd-resolved || systemctl restart systemd-resolved
# Add the systemd-resolved service to the bootstrap.
systemctl is-enabled --quiet systemd-resolved || systemctl enable systemd-resolved
