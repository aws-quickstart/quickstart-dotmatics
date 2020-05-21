#!/bin/bash
# @author Lucas Ko
# @year 2019

set -e
set -u
set -x


if [ -d "/symbolic_link" ]; then
    ls -la /symbolic_link
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

BIOREGISTER_WAR_FILE=$(ls /download_from_s3/bioregister*.war)
BIOREGISTER_WAR_COUNT=$(ls /download_from_s3/bioregister*.war | wc -l | xargs )

if [ "$BIOREGISTER_WAR_COUNT" -gt 1 ]; then
    echo "[ERROR] Too many bioregister installation war files."
    exit 1
elif [ "$BIOREGISTER_WAR_COUNT" -lt 1 ]; then
    echo "[ERROR] bioregister installation war file not found."
    exit 1
elif [ ! -f "$BIOREGISTER_WAR_FILE" ]; then
    echo "[ERROR] bioregister installation war file doesn't exist"
    exit 1
else
    unzip  -qq $BIOREGISTER_WAR_FILE -d $CATALINA_HOME/webapps/bioregister
    ls -ls $CATALINA_HOME/webapps/bioregister
fi


SRC_FILE=$BROWSER_PROP_FILE
FILE=browser.properties
mkdir -p webapps/browser/WEB-INF
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE
else
    echo "$SRC_FILE does not exist"
    exit 1
fi


SRC_FILE=$DOTMATICS_LICENSE_FILE
FILE=dotmatics.license.txt
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE
else
    echo "$SRC_FILE does not exist"
    exit 1
fi

SRC_FILE=$BIOREGISTER_GROOVY
FILE=bioregister.groovy
if [ -f "$SRC_FILE" ]; then
    ln -s $SRC_FILE $CATALINA_HOME/webapps/$FILE
else
    echo "$SRC_FILE does not exist"
    exit 1
fi


mkdir -p /c2c_attachments

chown -R tomcat:tomcat /c2c_attachments
chown -R tomcat:tomcat $CATALINA_HOME
chmod -R u-w  $CATALINA_HOME/conf
chmod -R u-w  $CATALINA_HOME/bin
chmod -R 770 /c2c_attachments

su -c "$CATALINA_HOME/bin/catalina.sh run" -s /bin/sh tomcat
