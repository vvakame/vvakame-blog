# vvaka.me 建設資材置き場

sudo /usr/local/bin/h2o -c $HOME/vvaka.me/h2o.conf

sudo letsencrypt certonly --standalone --email vvakame@gmail.com --domain blog.vvaka.me
curl -f "http://metadata.google.internal/computeMetadata/v1/project/attributes/letsencrypt-vvaka_me" -H "Metadata-Flavor: Google" | base64 -d > letsencrypt.zip

```
mkdir -p $HOME/pid $HOME/logs
sudo cp $HOME/vvaka.me/.systemd/h2o.service /etc/systemd/system/
sudo systemctl enable h2o
sudo systemctl restart h2o
systemctl status h2o
```

## 新しいブログポストを作る

```
$ ./node_modules/.bin/hexo new "記事名"
```
