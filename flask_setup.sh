#!/bin/bash


######################################
# Install Base dependencies
#######################################

sudo apt-get -y update
sudo apt-get -y install python3 python3-venv python3-dev
sudo apt-get -y install postfix supervisor nginx git
sudo apt-get -y install build-essential

# Install postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql libpq-dev


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
pip install gunicorn pygresql psycopg2

################################################################
# IMPORTANT :
# Create a .env file and save all your secrets here one might consider changing
# the keys string different from the development. Because if the project is open
# source and I want it to be in prod then anyone could mess with session and stuff

################################################################

# Set up database, for my app I am using Postgres
 
sudo -u postgres createuser -s $USER

read -rp $'Name of database you want to create' dbName
createdb $dbName

flask db upgrade

# I have a configuration file for gunicorn, supervusor and nginx
# so I am going to copy these config files into the right locations

# deactivate the python virtual environment and goto main directory
deactivate
cd 
# clone repo

echo "Clone repo with secrets and config files for gunicorn and nginx"

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
sudo cp boloWiki.conf /etc/supervisor/conf.d/

######################################
# Install ssl certificate, Nginx
######################################

sudo rm /etc/nginx/sites-enabled/default
# install ssl 
# This is for ubuntu 20 lts
sudo apt-get update
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx
sudo cp bolowiki /etc/nginx/sites-enabled/

# copy the nginx conf  based on loaction of where conf is stored
# It is typically one of /usr/local/nginx/conf, /etc/nginx, or /usr/local/etc/nginx.

echo "Copy the conf file for nginx, then reload nginx and supervisor"
