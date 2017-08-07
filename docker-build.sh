#! /bin/bash -eux

cd `dirname $0`

PROJECT_ID=vvakame-host
IMAGE_NAME=vvakame-blog
IMAGE_TAG=$(git rev-parse HEAD | cut -c 1-8)

docker build -t gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest .
docker tag gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}

# 試す
# docker run -p 8080:8080 gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest
# open http://localhost:8080/

gcloud docker -- push gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest
gcloud docker -- push gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}
