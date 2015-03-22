#!/bin/bash

## update repo.
sudo apt-get update

## install build tools for watson
sudo apt-get -y install wget
sudo apt-get -y install build-essential
sudo apt-get -y install cmake
sudo ln -f -s /usr/bin/make /usr/bin/gmake

## watson library dependencies. in order.
sudo apt-get -y install python-dev
sudo apt-get -y install uuid-dev
sudo apt-get -y install liblapack-dev
sudo apt-get -y install libgfortran3
sudo apt-get -y install gfortran
sudo apt-get -y install libclucene-dev

## ruby for s3 stuff
sudo apt-get install openssl
sudo apt-get -y install ruby
sudo apt-get -y install rubygems1.9.1
sudo apt-get -y install libopenssl-ruby
sudo apt-get -y install libssl-dev
sudo apt-get -y install s3cmd
