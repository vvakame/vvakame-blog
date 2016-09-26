# vvaka.me 建設資材置き場

sudo /usr/local/bin/h2o -c $HOME/vvaka.me/h2o.conf

sudo letsencrypt certonly --standalone --email vvakame@gmail.com --domain blog.vvaka.me

sudo cp $HOME/vvaka.me/.systemd/h2o.service /etc/systemd/system/
