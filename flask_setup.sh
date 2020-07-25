#!/bin/bash

######################################
# Install Base dependencies
#######################################

sudo apt-get -y update
sudo apt-get -y install python3 python3-venv python3-dev
sudo apt-get -y install mysql-server postfix supervisor nginx git


# These installations run mostly unattended, but at some point while you run 
# the third install statement you will be prompted to choose a root password for
# the MySQL service, and you ll also be asked a couple of questions regarding the
# installation of the postfix package which you can accept with their default 
# answers.

######################################
# Installing the Application
#######################################

read -rp $'address for the repo to clone :' repoAddress

read -rp $'Name of  the repo to clone :' repoName 

cd /var/www
sudo git clone $repoAddress
sudo chown -R $USER:$USER $repoName
cd $repoName
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install --upgrade pip
python3 -m pip install --upgrade setuptools
pip install -r requirements.txt
pip install gunicorn pymysql

################################################################
# IMPORTANT :
# Create a .env file and save all your secrets here one might consider changing
# the keys string different from the development. Because if the project is open
# source and I want it to be in prod then anyone could mess with session and stuff

################################################################

# Set up server for my app I am using MySql

# mysql -u root -p

################################################################
# enter password which was set initially during installation
# Now in mysql create a new db call it whatever you want also create a user 
# with the same name that has full access to it

# mysql> create database something character set utf8 collate utf8_bin;
# mysql> create user 'something'@'localhost' identified by '<db-password>';
# mysql> grant all privileges on something.* to 'something'@'localhost';
# mysql> flush privileges;
# mysql> quit;

################################################################

# flask db upgrade # Create db migration, Need to have flask migrate in app


######################################
# Setup Nginx
#######################################

######################################
# setup gunicorn and supervisor
#######################################
