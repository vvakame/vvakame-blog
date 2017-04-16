#!/bin/bash -eux

# sudo apt-get install certbot
sudo certbot certonly -n --webroot -w $HOME/vvaka.me/docroot -d blog.vvaka.me
sudo systemctl restart h2o

