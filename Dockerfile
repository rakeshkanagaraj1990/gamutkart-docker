FROM tomcat:latest
COPY target/gamutgurus.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]
