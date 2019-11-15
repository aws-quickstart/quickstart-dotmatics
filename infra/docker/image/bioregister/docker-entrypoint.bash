#!/bin/bash
# @author Lucas Ko
# @year 2019

set -e
set -u
set -x


if [ -d "/config" ]; then
    ls -la /config
fi

#  Waiting for browser
if [ -z "${SLEEP_TIME:-}" ]; then
    echo 'SLEEP_TIME' is not set
else
    echo "SLEEP_TIME is $SLEEP_TIME sec"
    date
    echo "Start sleeping for waiting browser get ready ..."
    sleep $SLEEP_TIME
    date
fi


SRC_FILE=$BROWSER_PROP_FILE
FILE=browser.properties
mkdir -p webapps/browser/WEB-INF
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE
else
    echo "$BROWSER_PROP_FILE does not exist"
fi


SRC_FILE=$BROWSER_LICENSE_FILE
FILE=dotmatics.license.txt
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE
else
    echo "$BROWSER_LICENSE_FILE does not exist"
fi

mkdir -p $CATALINA_HOME/webapps/bioregister
if ls $BIOREGISTER_WAR_FILE 1> /dev/null 2>&1; then
  echo "files do exist"
  unzip  -qq $BIOREGISTER_WAR_FILE -d $CATALINA_HOME/webapps/bioregister
else
    echo "$BIOREGISTER_WAR_FILE does not exist"
fi

SRC_FILE=$BIOREGISTER_GROOVY
FILE=bioregister.groovy
if [ -f "$SRC_FILE" ]; then
    ln -s $SRC_FILE $CATALINA_HOME/webapps/$FILE
else
    echo "$BIOREGISTER_GROOVY does not exist"
fi


mkdir -p /c2c_attachments

chown -R tomcat:tomcat /c2c_attachments
chown -R tomcat:tomcat $CATALINA_HOME
chmod -R u-w  $CATALINA_HOME/conf
chmod -R u-w  $CATALINA_HOME/bin

su -c "$CATALINA_HOME/bin/catalina.sh run" -s /bin/sh tomcat
