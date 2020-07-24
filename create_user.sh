# create a new user 
read -rp $'Enter the username for new user :' username
adduser --gecos "" $username
usermod -aG sudo $username
su $username
