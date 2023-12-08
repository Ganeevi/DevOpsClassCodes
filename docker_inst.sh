#!/bin/bash
sudo docker build -t myimage:$BUILD_NUMBER .
sudo docker run -itd -P myimage:$BUILD_NUMBER
