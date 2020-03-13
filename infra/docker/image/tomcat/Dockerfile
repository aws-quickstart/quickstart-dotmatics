FROM centos:7.6.1810
RUN  yum update -y && \
     yum install unzip glibc.i686 rsync -y

ENV CATALINA_HOME /usr/local/tomcat

### URL of Packages
ENV LIBREOFFICE_URL         http://mirrors.coreix.net/thedocumentfoundation/libreoffice/stable/6.2.8/rpm/x86_64/LibreOffice_6.2.8_Linux_x86-64_rpm.tar.gz
ENV CORRETTO_OPENJDK_URL    https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.rpm
ENV TOMCAT_URL              https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz
ENV FONT_CONFIG_URL         https://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/fontconfig-2.13.0-4.3.el7.x86_64.rpm
ENV DEJAVU_SANS_FONTS_URL   https://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/dejavu-sans-fonts-2.33-6.el7.noarch.rpm

### Downloading Installation Files
ADD $CORRETTO_OPENJDK_URL   /tmp/corretto_openjdk.rpm
ADD $TOMCAT_URL             /tmp/apache-tomcat.tar.gz
ADD $LIBREOFFICE_URL        /tmp/LibreOffice.tar.gz
ADD $FONT_CONFIG_URL        /tmp/fontconfig.rpm
ADD $DEJAVU_SANS_FONTS_URL   /tmp/dejavu_sans_fonts.rpm


### Package Installation
RUN yum localinstall -y /tmp/corretto_openjdk.rpm   && \
    yum localinstall -y /tmp/fontconfig.rpm         && \
    yum localinstall -y /tmp/dejavu_sans_fonts.rpm  && \
    rm -rf /tmp/corretto_openjdk.rpm                && \
    rm -rf /tmp/fontconfig.rpm                      && \
    rm -rf /tmp/dejavu_sans_fonts.rpm

RUN tar -zxf /tmp/LibreOffice.tar.gz -C /tmp  && \
    rm /tmp/LibreOffice.tar.gz && \
    mv /tmp/LibreOffice_*_rpm /tmp/LibreOffice  && \
    yum localinstall -y  /tmp/LibreOffice/RPMS/*.rpm   && \
    rm -rf /tmp/LibreOffice*

RUN tar -zxf /tmp/apache-tomcat.tar.gz -C /usr/local && \
    rm /tmp/apache-tomcat.tar.gz && \
    mv /usr/local/apache-tomcat-* $CATALINA_HOME  && \
    chmod +x $CATALINA_HOME/bin/* && \
    chmod 0644 $CATALINA_HOME/conf/* && \
    rm -rf $CATALINA_HOME/webapps/ROOT  \
           $CATALINA_HOME/webapps/docs  \
           $CATALINA_HOME/webapps/examples  \
           $CATALINA_HOME/webapps/host-manager \
           $CATALINA_HOME/webapps/manager


### Permission Setup
RUN groupadd tomcat &&\
    useradd  -u 1000 -ms /bin/false -g tomcat tomcat &&\
    chown -R tomcat:tomcat $CATALINA_HOME  && \
    chown -R tomcat:tomcat /opt/libreoffice*  && \
    chmod -R 755 $CATALINA_HOME/webapps/

WORKDIR /usr/local/tomcat
EXPOSE 8080

COPY docker/image/tomcat/goss /goss/tomcat

RUN  chmod +x /goss/tomcat/install && \
     /goss/tomcat/install && \
     goss -g /goss/tomcat/goss-buildtime.yaml validate

HEALTHCHECK --interval=30s --timeout=30s --retries=5 CMD goss -g /goss/tomcat/healthcheck.yaml validate

CMD ["/usr/local/tomcat/bin/catalina.sh" , "run"]