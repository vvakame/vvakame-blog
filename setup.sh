#!/bin/bash -eux

H2O_VERSION=2.0.4
rm -rf h2o-${H2O_VERSION}
curl -L -o h2o.zip https://github.com/h2o/h2o/archive/v${H2O_VERSION}.zip
unzip h2o.zip
cd h2o-${H2O_VERSION}
cmake -DWITH_BUNDLED_SSL=on .
make
sudo make install

git submodule init && git submodule update
yarn install
