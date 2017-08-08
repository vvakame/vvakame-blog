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

## ローカルでh2oの動作を確かめる

```
$ brew install mruby h2o
$ h2o -c h2o.conf
```

## 環境立ち上げる

```
# 最初に1回だけ実行する

CLOUDSDK_CORE_PROJECT=vvakame-host
CLUSTER_NAME=vvakame-blog
GCP_ZONE=asia-northeast1-b
LEGO_EMAIL=vvakame@gmail.com
LEGO_URL=https://acme-v01.api.letsencrypt.org/directory

$ gcloud compute addresses create gke-ingress-static-blog --global

$ gcloud container --project $CLOUDSDK_CORE_PROJECT clusters create $CLUSTER_NAME \
  --zone $GCP_ZONE \
  --cluster-version "1.7.2" --machine-type "n1-standard-1" --image-type "COS" --disk-size "100" \
  --num-nodes "3" --network "default" \
  --enable-cloud-logging --enable-cloud-monitoring --enable-autoscaling --min-nodes "3" --max-nodes "3" --enable-autoupgrade \
  --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/bigquery","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/pubsub","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"

# kubectlを使えるようにするためにクラスタの認証情報を読み込む
$ gcloud container clusters get-credentials $CLUSTER_NAME --zone $GCP_ZONE --project $CLOUDSDK_CORE_PROJECT

$ helm init
$ helm install --name blog-crt --set config.LEGO_EMAIL=${LEGO_EMAIL} --set config.LEGO_URL=${LEGO_URL} stable/kube-lego
```

```
$ ./docker-build.sh
$ ./deploy.sh
```

```
# k8sコンソールの表示
$ kubectl proxy
$ open http://localhost:8001/ui

# Podに入って何か叩いたり
$ kubectl get pod
$ kubectl exec -it $POD_NAME /bin/sh

# 特定のPodのWebにアクセスしたり
$ kubectl port-forward $POD_NAME 8080

# （各Podの標準出力）ログを見る
# brew install stern
$ stern api

# その他
$ kubectl get svc
$ kubectl describe ingress
$ kubectl delete ing api-ingress
$ kubectl top node
```
