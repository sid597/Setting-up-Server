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

# Set up database, for my app I am using MySql
# Following code is copied from bolowiki/database_setup.sh

# use tts(text to speech) the database name : for me
# user name you know : for me

read -rp $'Enter username for db :' user 
read -rp $'Enter password for db :' password 
read -rp $'Enter database name  :' database
 
function execAsRoot() {

    command=${1}
    sudo mysql --user="root" --password=""  --execute="$command"
}

function execAsUser() {
    command=${1}
    sudo mysql --user="$user" --password="$password" --database="$database" --execute="$command"

}

execAsRoot "create database $database character set utf8 collate utf8_bin;"
execAsRoot "create user '$user'@'localhost' identified by '$password';"
execAsRoot "grant all privileges on $database.* to '$user'@'localhost';"
execAsRoot "flush privileges;"

export FLASK_APP=bolowikiApp/__init__.py
export FLASK_ENV=development      
flask db upgrade


# I have a configuration file for gunicorn, supervusor and nginx
# so I am going to copy these config files into the right locations

# deactivate the python virtual environment and goto main directory
deactivate
cd 
# clone repo


read -rp $'address for the repo with ngin etc. conf to clone :' repoAddress
sudo git clone $repoAddress
sudo chown -R $USER:$USER $repoName
cd $repoName

######################################
# setup gunicorn and supervisor
#######################################

# copy the supervisor conf
# the conf looks like :
# [program:bolowiki]
# command=/var/www/bolowiki/venv/bin/gunicorn -b localhost:8000 -w 4 run:app
# directory=/var/www/bolowiki
# user=sid597
# autostart=true
# autorestart=true
# stopasgroup=true
# killasgroup=true
cp boloWiki.conf /etc/supervisor/conf.d/

######################################
# Install ssl certificate, Nginx
######################################

sudo rm /etc/nginx/sites-enabled/default
# install ssl 
# This is for ubuntu 18
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update

sudo apt-get install certbot python3-certbot-nginx

sudo certbot --nginx

# copy the nginx conf  based on loaction of where conf is stored
# It is typically one of /usr/local/nginx/conf, /etc/nginx, or /usr/local/etc/nginx.

echo "Copy the conf file for nginx, then reload nginx and supervisor"