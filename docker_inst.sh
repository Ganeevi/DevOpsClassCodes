#!/bin/bash
sudo docker build -t myimage:${env.BUILD_ID} .
sudo docker run -itd -P myimage:${env.BUILD_ID}
