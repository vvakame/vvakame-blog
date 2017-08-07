#!/bin/bash -eux

git submodule init && git submodule update
yarn install
