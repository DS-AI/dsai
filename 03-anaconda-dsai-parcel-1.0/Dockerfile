ARG RELEASE
FROM oraclelinux:${RELEASE}-slim


# Install common packages.
RUN yum install -y bzip2 gawk gzip java tar unzip which


# Install Anaconda
COPY assets/Anaconda*.sh /root/
COPY assets/*.py /root/
COPY assets/*.whl /root/

COPY assets/install.sh /root/

ARG RELEASE
ARG DSAI_VERSION
RUN /root/install.sh ${RELEASE} ${DSAI_VERSION}


# Make parcel.
COPY assets/parcel.json /root/
COPY assets/conda_env.sh /root/

COPY assets/parcel.sh /root/

ARG RELEASE
RUN /root/parcel.sh ${RELEASE}


# Validate parcal.
COPY assets/validator.jar /root/

COPY assets/validate.sh /root/

ARG RELEASE
RUN /root/validate.sh ${RELEASE}


# Copy parcel out.
RUN mkdir /root/out

CMD find /opt/cloudera/parcels/ -name '*.parcel' -exec cp {} /root/out/ \;
