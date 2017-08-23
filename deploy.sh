#! /bin/bash -eux

cd `dirname $0`

PROJECT_ID=vvakame-host
IMAGE_NAME=vvakame-blog
IMAGE_TAG=$(git rev-parse HEAD | cut -c 1-8)
DOCKER_IMAGE=gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}
CLUSTER_NAME=vvakame-blog

TMPL_DIR=k8s/template
GEN_DIR=k8s/generated

rm -rf $GEN_DIR
mkdir -p $GEN_DIR
cp $TMPL_DIR/blog-hpa-rs.yml $TMPL_DIR/blog-service.yml $TMPL_DIR/ingress.yml $GEN_DIR
cat $TMPL_DIR/blog-deployment.yml | sed "s#\${DOCKER_IMAGE}#${DOCKER_IMAGE}#" > $GEN_DIR/blog-deployment.yml

gcloud --quiet container clusters get-credentials $CLUSTER_NAME

kubectl apply -f $GEN_DIR
