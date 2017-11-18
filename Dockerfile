FROM centos:6.9
MAINTAINER Jaeger <JaegerCode@gmail.com>

ADD install.sh /root/
ADD start.sh /

USER root

RUN yum -y install initscripts wget curl && sh /root/install.sh 2>&1 | tee /root/install.log

RUN yum clean all

EXPOSE 80 8090

RUN chmod +x /start.sh 

CMD /start.sh


