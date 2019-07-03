FROM quay.io/openshiftlabs/workshop-dashboard:3.3.2

USER root

RUN yum -y install hub 

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

ENV TERMINAL_TAB=split A=b

USER 1001

RUN /usr/libexec/s2i/assemble
