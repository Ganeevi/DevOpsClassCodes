#!/bin/bash
sudo rm -rf /docker-file
ls -l /docker-file/
sudo mkdir /docker-file
cd /docker-file
sudo cp -pr /tmp/workspace/pipeline-as-code/target/addressbook.war .
sudo touch dockerfile
cat << EOT >> dockerfile
FROM tomcat
MAINTAINER Ramandeep Singh
COPY addressbook.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD [ "catalina.sh", "run" ]
EOT
ls -l /docker-file/
