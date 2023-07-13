#to configure spring libraries
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn dependency:resolve
RUN mkdir -p /app/dependencies
RUN mvn dependency:copy-dependencies -DincludeScope=runtime -DoutputDirectory=/app/dependencies


# Base OS
FROM ubuntu:latest

RUN apt-get update && apt-get install -y openjdk-11-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN apt-get install -y tomcat9
EXPOSE 8080

RUN apt-get install -y wget && \
    wget -O eclipse.tar.gz "https://eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2021-06/R/eclipse-java-2021-06-R-linux-gtk-x86_64.tar.gz&r=1" && \
    tar -xzf eclipse.tar.gz && \
    rm eclipse.tar.gz && \
    mv eclipse /opt/eclipse

RUN apt-get install -y mysql-server
RUN service mysql start && \
    mysql -e "CREATE USER 'root' IDENTIFIED BY '123456';" && \
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root';" && \
    mysql -e "FLUSH PRIVILEGES;"

ENV CATALINA_HOME=/usr/share/tomcat9
ENV CATALINA_BASE=/var/lib/tomcat9
ENV CLASSPATH=/opt/spring-libraries/*:$CLASSPATH

WORKDIR $CATALINA_HOME

CMD ["catalina.sh", "run"]
