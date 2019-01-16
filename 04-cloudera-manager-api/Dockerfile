FROM oraclelinux:7-slim

RUN yum --enablerepo ol7_optional_latest install -y maven

WORKDIR /root/

RUN mkdir /root/.m2
COPY maven-settings.xml /root/.m2/settings.xml

COPY pom.xml /root/

RUN mvn dependency:copy-dependencies

CMD find /root/target/dependency/ -name '*.jar' -exec cp {} /root/out/ \;
