FROM oraclelinux:7-slim

RUN yum install -y rpm-build

COPY cloudera-cdh5.repo /etc/yum.repos.d/

WORKDIR /root

RUN yumdownloader --source spark-core-1.6.0+cdh5.15.1+570-1.cdh5.15.1.p0.4

RUN groupadd jenkins && useradd -g jenkins jenkins

RUN find . -type f -name '*.src.rpm' -exec basename {} \; | xargs rpm -ivh

RUN yum-builddep spark-core

COPY jdk-8u191-linux-x64.rpm /tmp/

RUN mkdir -p /usr/share/man/man1 \
    && yum localinstall -y /tmp/jdk-8u191-linux-x64.rpm \
    && rm /tmp/jdk-8u191-linux-x64.rpm

ENV JAVA_HOME=/usr/java/default

RUN yum install -y rsync

WORKDIR /root/rpmbuild

COPY NOCDH4.diff /tmp
COPY APACHE_MIRROR.diff /tmp
COPY SPARK-19019.patch /root/rpmbuild/SOURCES/
COPY SPARK-4563.patch /root/rpmbuild/SOURCES/

RUN patch -d /root/rpmbuild/SOURCES -p0 -i /tmp/NOCDH4.diff \
    && rm /tmp/NOCDH4.diff
RUN patch -d /root/rpmbuild/SOURCES -p0 -i /tmp/APACHE_MIRROR.diff \
    && rm /tmp/APACHE_MIRROR.diff

COPY spark.spec SPECS/spark.spec

RUN mkdir /root/.m2
COPY maven-settings.xml /root/.m2/settings.xml 

RUN rpmbuild -ba SPECS/spark.spec

RUN mkdir /root/out

CMD find /root/rpmbuild/RPMS/ -name '*.rpm' -exec cp {} /root/out/ \;

