#!/bin/bash
# @author Laurent Krishnathas
# @year 2018

set -e
set -u
set -x

if [ -d "/config" ]; then
    ls -la /config
fi
mkdir -p $CATALINA_HOME/webapps/browser
BROWSER_ZIP_FILE=$(ls /config/browser-*.zip )
BROWSER_ZIP_COUNT=$(ls /config/browser-*.zip | wc -l | xargs )

if [ "$BROWSER_ZIP_COUNT" -gt 1 ]; then
    echo "[ERROR] Too many browser installation zip files."
    exit 1
elif [ "$BROWSER_ZIP_COUNT" -lt 1 ]; then
    echo "[ERROR] Browser installation zip file not found."
    exit 1
elif [ ! -f "$BROWSER_ZIP_FILE" ]; then
    echo "Browser installation zip file doesn't exist"
    exit 1
else
    unzip  -qq $BROWSER_ZIP_FILE -d $CATALINA_HOME/webapps/browser
    ls -ls $CATALINA_HOME/webapps/browser
fi

if [ -d "/config/browser" ]; then
    ls -ls /config/browser
    ls -ls $CATALINA_HOME/webapps/browser
    echo "Overwriting files from /config/browser/ to $CATALINA_HOME/webapps/browser ... "
    rsync -au /config/browser/  $CATALINA_HOME/webapps/browser/
fi

SRC_FILE=$BROWSER_PROP_FILE
FILE=browser.properties
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE
else
    echo "$SRC_FILE does not exist"
    exit 1
fi

SRC_FILE=$BROWSER_LICENSE_FILE
FILE=dotmatics.license.txt
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE
else
    echo "$SRC_FILE does not exist"
    exit 1
fi

chown -R tomcat:tomcat $CATALINA_HOME
chmod -R u-w  $CATALINA_HOME/conf
chmod -R u-w  $CATALINA_HOME/bin

chmod 755  /usr/local/tomcat/webapps/browser/pdf
chmod 755  /usr/local/tomcat/webapps/browser/tempfiles
chmod 755  /usr/local/tomcat/webapps/browser/images/profiles

find /usr/local/tomcat/webapps/browser/ -name "raw data" -type d | xargs -I {} chmod -R 755 "{}"
ls -ls /usr/local/tomcat/webapps/browser/

su -c "$CATALINA_HOME/bin/catalina.sh run" -s /bin/sh tomcat
