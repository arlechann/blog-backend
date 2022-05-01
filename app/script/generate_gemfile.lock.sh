#!/bin/sh

docker run --rm -v "$PWD":/opt/blog -w /opt/blog ruby:3.1.1 bundle install
