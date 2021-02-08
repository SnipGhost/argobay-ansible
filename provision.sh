apt update
apt -y upgrade
useradd -m ansible
echo "ansible    ALL=(ALL:ALL) ALL" >> /etc/sudoers
passwd ansible
