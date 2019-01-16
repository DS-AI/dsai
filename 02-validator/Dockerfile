FROM oraclelinux:7-slim

WORKDIR /root

# Install common packages.
RUN yum --enablerepo ol7_optional_latest install -y java-devel maven unzip

RUN curl -L https://github.com/cloudera/cm_ext/archive/master.zip -O \
    && unzip master.zip

RUN cd /root/cm_ext-master \
    && mvn install

RUN mkdir /root/out \
    && ls -l /root/cm_ext-master/validator/target/validator.jar

CMD cp /root/cm_ext-master/validator/target/validator.jar /root/out
