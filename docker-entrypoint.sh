#!/bin/bash

if [ ! -d "./node_modules" ]; then
    echo "Installing NPM dependencies..."
    npm install
fi

if [ -n "$SIGMA_BLOG_DOCKER" ]; then
    echo "Hexo server's file watching might not work in docker container. Manually restart docker container if so."
fi

echo "Starting Hexo server."
hexo server $@
echo "Hexo server exited."
