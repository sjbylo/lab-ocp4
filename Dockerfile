FROM quay.io/openshifthomeroom/workshop-dashboard:5.0.0
#FROM quay.io/openshiftlabs/workshop-dashboard:3.6.3

USER root

# Tools needed for the workshop
RUN yum -y install hub mysql 
#RUN curl -sLO https://download.svcat.sh/cli/latest/linux/amd64/svcat && chmod +x ./svcat && mv ./svcat /usr/local/bin
RUN curl -sLO https://download.svcat.sh/cli/v0.2.2/linux/amd64/svcat && chmod +x ./svcat && mv ./svcat /usr/local/bin

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

ENV TERMINAL_TAB=split

USER 1001

RUN /usr/libexec/s2i/assemble
