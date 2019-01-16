FROM oraclelinux:7-slim


WORKDIR /root


# Local repositories only
RUN rm -rf /etc/yum.repos.d/* \
    && mkdir -p /var/yum/localrepo/

COPY assets/rpms/*.rpm /var/yum/localrepo/

RUN yum localinstall -y /var/yum/localrepo/createrepo-0.9.9-28.el7.noarch.rpm /var/yum/localrepo/deltarpm-3.6-3.el7.x86_64.rpm /var/yum/localrepo/python-deltarpm-3.6-3.el7.x86_64.rpm \
    && createrepo /var/yum/localrepo/ 

COPY assets/local.repo /etc/yum.repos.d/


# Install common packages (required by Anaconda installer etc).
RUN yum install -y bzip2 initscripts tar unzip


# Install and configure PBIS and PAM

# Install PAM itself and standard PAM configuration packages.
RUN yum install -y pam util-linux \
# Here we just download PBIS RPM packages then install them omitting scripts.
# We don't need scripts since they start PBIS services, which are not used - we connect to the host services instead.
    && find /var/yum/localrepo/ -type f -name 'pbis-open*.rpm' | xargs rpm -ivh --noscripts \
# Enable PBIS PAM integration.
    && domainjoin-cli configure --enable pam \
# Make pam_loginuid.so module optional (Docker requirement) and add pam_mkhomedir.so to have home directories created automatically.
    && mv /etc/pam.d/login /tmp \
    && awk '{ if ($1 == "session" && $2 == "required" && $3 == "pam_loginuid.so") { print "session    optional     pam_loginuid.so"; print "session    required     pam_mkhomedir.so skel=/etc/skel/ umask=0022";} else { print $0; } }' /tmp/login > /etc/pam.d/login \
    && rm /tmp/login \
# Enable PBIS nss integration.
    && domainjoin-cli configure --enable nsswitch


# Cloudera Manager and Java.
RUN mkdir -p /usr/share/man/man1

RUN yum install -y cloudera-manager-daemons cloudera-manager-server cloudera-manager-server-db-2 cloudera-manager-agent jdk1.8 ntp jq


# JCE extensions.
COPY assets/jce_policy-8.zip /tmp/
RUN cd /tmp/ \
    && unzip jce_policy-8.zip \
    && cp UnlimitedJCEPolicyJDK8/local_policy.jar /usr/java/default/jre/lib/security/ \
    && cp UnlimitedJCEPolicyJDK8/US_export_policy.jar /usr/java/default/jre/lib/security/ \
    && rm /tmp/jce_policy-8.zip


# Make runuser happy.
RUN echo -e 'cloudera-scm    soft  nofile  32768\ncloudera-scm    soft  nproc   65536\ncloudera-scm    hard  nofile  65536\ncloudera-scm    hard  nproc   unlimited' > /etc/security/limits.d/cloudera-scm.conf


# Copy parcels and generate sha1.

COPY assets/parcels/*.parcel /opt/cloudera/parcel-repo/

RUN for F in `ls -1 /opt/cloudera/parcel-repo/*.parcel`; do sha1sum $F | awk '{ print $1; }' > $F.sha; done \
    && chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo/*


# Patch agent config to use localhost only.
RUN sed -i 's/# listening_ip=/listening_ip=127.0.0.1/g' /etc/cloudera-scm-agent/config.ini \
    && sed -i 's/# listening_hostname=/listening_hostname=localhost/g' /etc/cloudera-scm-agent/config.ini \
    && sed -i 's/# reported_hostname=/reported_hostname=localhost/g' /etc/cloudera-scm-agent/config.ini


# Install parcels.
COPY assets/install-parcels/ /root/

RUN /etc/init.d/cloudera-scm-server-db start \
    && /etc/init.d/cloudera-scm-server start \
    && /etc/init.d/cloudera-scm-agent start \
    && /root/bin/install-parcels.sh \
    && while ! /etc/init.d/cloudera-scm-agent stop; do : ; done \
    && while ! /etc/init.d/cloudera-scm-server stop; do : ; done \
    && while ! /etc/init.d/cloudera-scm-server-db stop; do : ; done



# Patch Spark.
COPY assets/spark-patch/spark-assembly-*.jar /opt/cloudera/parcels/CDH/jars/
COPY assets/spark-patch/cloudpickle.py /opt/cloudera/parcels/CDH/lib/spark/python/pyspark/
COPY assets/spark-patch/serializers.py /opt/cloudera/parcels/CDH/lib/spark/python/pyspark/


# Oracle libraries.
RUN mkdir -p /opt/oracle/bigdatasql/bdcell-12.1/jlib/

COPY assets/oracle/* /opt/oracle/bigdatasql/bdcell-12.1/jlib/


# Setup Hadoop config.
RUN alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.cloudera.yarn/ 92 \
    && alternatives --set hadoop-conf /etc/hadoop/conf.cloudera.yarn/

# Setup Spark config.
RUN alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.cloudera.spark_on_yarn/ 51 \
    && alternatives --set spark-conf /etc/spark/conf.cloudera.spark_on_yarn/

# Setup Spark 2 config.
RUN alternatives --install /etc/spark2/conf spark2-conf /etc/spark2/conf.cloudera.spark2_on_yarn/ 51 \
    && alternatives --set spark2-conf /etc/spark2/conf.cloudera.spark2_on_yarn/


# Folder for binaries.
RUN mkdir -p /opt/dsai/bin/


# Setup kernels etc.
COPY assets/jupyterhub/* /root/
RUN /root/setup.sh


# Install libraries.
RUN yum install -y rhash unixODBC boost


# Fix lineage error.
RUN mkdir -p /var/log/{spark,spark2}/lineage \
    && chown -R spark:spark /var/log/{spark,spark2} \
    && chmod a+w /var/log/{spark,spark2}/lineage


# Setup PATH.
ENV PATH="/opt/pbis/bin/:/opt/cloudera/parcels/Anaconda/bin/:$PATH"


# Start JupyterHub.
CMD ["bash", "-c", "/root/run.sh"]
