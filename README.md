# Setting up server to deploy Flask app 

 NOTE : I am using Ubuntu to set up this server

I followed the following steps to set up my server for flask app this guide is for future reference.

## Hosting Options
One can host websites on their own bare-metal hardware or on virtualized 
servers I decided to go with the latter option.

Now here also ther are multiple options to choose from : Linode, Digital Ocean,
AWS, GCE etc. I went with digital ocean because I got $100 free credit and 
I found options from AWS and GCE confusing with their naming scheme.

If you want to set up your server on digital ocean with $100 credit, here is 
my referal link https://m.do.co/c/55d364734c11. Go spend >$25 only then I will
get another $25 credit :)


Once decided to go with Digital ocean then:
    - Sign in
    - Click on create -> droplets
    - All the info will be on the page to help you decide your setup
    - I set up the server with password not ssh so had to convert to ssh login
      later.
    - My tip go with the backup options it will be worth it, more so if you 
      decided to develop on server directly

## Initial Server set up with Ubuntu 18.04
    
There are a few steps that should be done as a basic setup to increase the
security and usability of server.

#### Login as root

- Connect you droplet with ssh from your machine

 -  To connect with ssh as root one needs to know the IP of their droplet
    grab that then do `ssh root@ip_address`
 - Accept warnings that are displayed
 - ##### Set up ssh key insted of password authentication 

    - Go to your machine terminal 
    - If you already have ssh key 
        - Copy your **public key** `ssh-copy-id username@remote_host`
    - Else 
        - Generate ssh key using `ssh keygen`
        - Copy your **public key** `ssh-copy-id username@remote_host`
    - Try logging to serve with `ssh username@remote_host`
    - If successful continue else go figure why this happend
    - Disable password authentication for server 
        - `sudo vi /etc/ssh/sshd_config`
        - Learn vim commands if you find yourself stuck
        - Search for `PasswordAuthentication` uncomment if this is commented out
          and set it to no.
        - Pro tip: exit vi by following the steps: 
          press `esc` -> type `:wq`-> Give a pat on back  Phew! 
    - restart `sshd` service `sudo systemctl restart ssh`

 Now once logged in as a root user, use your great power to create a new 
 sudo user

#### Create New User

- `adduser Kenzo_Tenma`
- Skip or enter the details asked
- Grant the new user sudo privileges `usermod -aG sudo Kenzo_Tenma`
- ##### Enabling external access for this regular user
    - Why ? So that I can directly ssh into this account
    - Copy the ssh key to this users authorized keys from root
    - `rsync --archive --chown=Kenzo_Tenma:Kenzo_Tenma ~/.ssh /home/Kenzo_Tenma


#### Set up basic firewall 

In digital ocean there is an option to set up firewall( create -> cloud firewalls)
I tried that option but later I was not able get my nginx working so
I reverted back to using ufw(uncomplicated firewall) also if something does
not workout there are tons of articles and support where you can find 
solution to ufw related issue. 

- Allow ssh through firewall 

    - `ufw allow OpenSSH`
    - `ufw enable` => enables the firewall check the status using `ufw status`

    NOTE: This is a basic server setup as of this point only ssh is possible
          for Nginx server we will also need to allow http and https.

#### Set up the working environment (Optional)

At this point I would like to install a few programs:
vim, zsh, terminator, oh-my-zsh and update their necessary config files



NOTE : You have to do all the work now in user account not root

## Install Nginx and update firewall 
- `sudo apt update`
- `sudo apt install nginx`
- `sudo ufw app list` will show all the application configurations that ufw knows
- `sudo ufw allow 'Nginx HTTP'` allow http requests, if you have ssl then also 
    allow HTTPS
- `sudo ufw enable nginx` -> Will enable nginx, so if you go to your ip in browser
    you will see nginx installed html page

## Install python, pip etc. on server
    
Now its time to install dependencies to run you python virtual environment
 - `sudo apt update`
 - `sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptoolsi `
 - `sudo apt install python3-venv` install package to make virtual environment,
    there are many packages for python to make virtual env but I use python3 
    because thats what all the tutorial makers used :D
 - Make or copy the project you want in server to `/var/www/`
 - `python3.6 -m venv venv` creates a virtual env called venv(the latter one)
 - `source venv/bin/activate`


## Setting up flask 
    
If copying project from local to server install all the packages for the project
 - In you local machine create a requirements.txt file which will contain all the
   packages required for the project `pip freeze > requirements.txt` will create the
   file
 - create a virtual environment
 - `pip install wheel` this is necessary dependency for some packages that does not 
    have wheel archives
 - Install the packages from requirements.txt using command `pip install -r requirements.txt`
 #### Create a WSGI entry point 

    - `vim /path-toproject/wsgi.py`
    > ```
       from __init__ import app
        import os
        app.secret_key = os.environ.get("FLASK_APP_SECRET_KEY")
        if __name__ == "__main__":
            app.run()

       ``` 
  - `deactivate`

     
## Configuring Gunicorn


- `sudo vim /etc/systemd/system/projectname.service` 
```
[Unit]
Description=Gunicorn instance to serve myproject
After=network.target

[Service]
User=sammy
Group=www-data
WorkingDirectory=/var/www/myproject
Environment="PATH=/var/www/myproject/venv/bin"
ExecStart=/var/www/myproject/venv/bin/gunicorn --workers 3 --bind unix:myproject.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
```

- `sudo systemctl start myproject`
- `sudo systemctl enable myproject`
    
## Configuring Nginx to Proxy Requests

- `sudo vim /etc/nginx/sites-available/myproject`

```
server {

    listen 80;
    server_name 206.189.134.65;

    location /static {
        alias /var/www/myproject/static;
    }

    location / {
        proxy_pass http://unix:/var/www/myproject/myproject.sock;
        include /etc/nginx/proxy_params;
        proxy_redirect off;
    }


}
```

- `sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled`
- `sudo nginx -t`  check nginx for errors
- `sudo systemctl restart nginx`



## Conclusion 

In this guide, you created and secured a simple Flask application within a Python virtual environment. You created a WSGI entry point so that any WSGI-capable application server can interface with it, and then configured the Gunicorn app server to provide this function. Afterwards, you created a systemd service file to automatically launch the application server on boot. You also created an Nginx server block that passes web client traffic to the application server, relaying external requests, and secured traffic to your server with Let’s Encrypt.

Flask is a very simple, but extremely flexible framework meant to provide your applications with functionality without being too restrictive about structure and design. You can use the general stack described in this guide to serve the flask applications that you design.



















