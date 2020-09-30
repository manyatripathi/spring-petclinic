FROM maven:3.5-jdk-8-alpine
ENV APP_FILE='*-2.3.0.BUILD-SNAPSHOT.jar' \
APP_HOME=/usr/app
EXPOSE 8080 
RUN mvn package
COPY target/$APP_FILE $APP_HOME/
CMD java -jar $APP_HOME/$APP_FILE
