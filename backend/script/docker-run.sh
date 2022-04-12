#!/bin/sh

docker run -it --rm -p 4567:4567 blog-api bundle exec ruby app.rb -o 0.0.0.0
