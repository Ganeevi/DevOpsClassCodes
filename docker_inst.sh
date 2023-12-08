#!/bin/bash
sudo docker build -t myimage:${env.BUILD_NUMBER} .
sudo docker run -itd -P myimage:${env.BUILD_NUMBER}
