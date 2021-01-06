#!/bin/bash

# Execute a command as a certain user
# Arguments:
#   Account Username
#   Command to be executed
function execAsUser() {
    local username=${1}
    local exec_command=${2}

    sudo -u "${username}" -H bash -c "${exec_command}"
}

# Add the local machine public SSH Key for the new user account
# Arguments:
#   Account Username
#   Public SSH Key
function addSSHKey() {
    local username=${1}
    local sshKey=${2}

    execAsUser "${username}" "mkdir -p ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys"
    execAsUser "${username}" "echo \"${sshKey}\" | sudo tee -a ~/.ssh/authorized_keys"
    execAsUser "${username}" "chmod 600 ~/.ssh/authorized_keys"
}

# Keep prompting for the password and password confirmation
function promptForPassword() {
   PASSWORDS_MATCH=0
   while [ "${PASSWORDS_MATCH}" -eq "0" ]; do
       read -s -rp "Enter new UNIX password:" password
       printf "\n"
       read -s -rp "Retype new UNIX password:" password_confirmation
       printf "\n"

       if [[ "${password}" != "${password_confirmation}" ]]; then
           echo "Passwords do not match! Please try again."
       else
           PASSWORDS_MATCH=1
       fi
   done 
}
# NOTE : I don't assume any empty or nonsense fields

#######################
# Password less login 
########################

# create a new user 
read -rp $'Enter the username for new user :' username
promptForPassword
sudo adduser --disabled-password --gecos '' $username
echo "${username}:${password}" | sudo chpasswd
sudo usermod -aG sudo $username


# Add your local pc ssh public key

# use this command to get a hold of key in local :

echo "Get your ssh key:  cat ~/.ssh/id_rsa.pub"
read -rp $'Paste your ssh key : ' sshKey
addSSHKey "${username}" "${sshKey}"

# Disable password login and root logins

SSHD_CONFIG_FILE_PATH="/etc/ssh/sshd_config"

sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g"  $SSHD_CONFIG_FILE_PATH
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g"  $SSHD_CONFIG_FILE_PATH

sudo service ssh restart

echo "ssh server restarted"



###################
# securing server
###################




# Install Firewalls 
execAsUser "${username}" "sudo apt-get install -y ufw"
execAsUser "${username}" "sudo ufw allow ssh"
execAsUser "${username}" "sudo ufw allow http"
execAsUser "${username}" "sudo ufw allow 443/tcp"
execAsUser "${username}" "sudo ufw --force enable"
execAsUser "${username}" "sudo ufw status"


###########################
# Install softwares 
##########################

# execAsUser "${username}" "sudo apt update"
# execAsUser "${username}" "sudo apt upgrade"
execAsUser "${username}" "sudo apt-get install vim "

echo "#############################################"
echo "Vim Installed"
echo "#############################################"

execAsUser "${username}" "sudo apt install zsh"

echo "#############################################"
echo "Zsh Installed"
echo "#############################################"

execAsUser "${username}" "sudo apt-get install terminator"

echo "#############################################"
echo "Terminator Installed"
echo "#############################################"




#########################
# Clone configs
########################

execAsUser "${username}" "cd;sudo git clone https://github.com/sid597/config.git"



#########################
# Clone this repo
########################
execAsUser "${username}" "cd;sudo git clone https://github.com/sid597/Setting-up-Server.git"

execAsUser "${username}" "cd;sudo chown -R $username:$username Setting-up-Server"
execAsUser "${username}" "cd;sudo chown -R $username:$username config"

# Install oh my zsh
execAsUser "${username}" 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
