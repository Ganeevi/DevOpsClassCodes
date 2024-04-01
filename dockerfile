FROM tomcat
MAINTAINER Ramandeep Singh
COPY addressbook.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]
EXPOSE 8080
