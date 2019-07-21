#!/bin/sh
apt update
apt install ruby-full ruby-bundler build-essential -y
ruby -v
bundler -v 