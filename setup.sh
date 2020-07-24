#!/bin/bash

# NOTE : I don't assume any empty or nonsense fields

#######################
# Password less login 
########################

# Create a new user 
read -rp $'Enter the username for new user :' username
adduser --gecos "" $username
usermod -aG sudo $username
su $username

# Add your local pc ssh public key

# use this command to get a hold of key in local :
# cat ~/.ssh/id_rsa.pub

read -rp $'Paste your ssh key : ' sshKey

echo $sshKey >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

###################
# securing server
###################

# Disable password login and root logins

SSHD_CONFIG_FILE_PATH="/etc/ssh/sshd_config"

sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g"  SSHD_CONFIG_FILE_PATH
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g"  SSHD_CONFIG_FILE_PATH

sudo service ssh restart


# Install Firewalls 
sudo apt-get install -y ufw
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status


###########################
# Install softwares 
##########################

sudo apt update
sudo apt upgrade
sudo apt-get install vim 
sudo apt install zsh
sudo apt-get install terminator
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set terminator default terminal
