#!/bin/bash

set -e
set -u
set -x

if [ -d "/symbolic_link" ]; then
    ls -la /symbolic_link
fi
mkdir -p $CATALINA_HOME/webapps/vortexweb
VORTEX_ZIP_FILE=$(ls /download_from_s3/vortexweb*.zip )
VORTEX_ZIP_COUNT=$(ls /download_from_s3/vortexweb*.zip | wc -l | xargs )

if [ "$VORTEX_ZIP_COUNT" -gt 1 ]; then
    echo "[ERROR] Too many vortex installation zip files."
    exit 1
elif [ "$VORTEX_ZIP_COUNT" -lt 1 ]; then
    echo "[ERROR] vortex installation zip file not found."
    exit 1
elif [ ! -f "$VORTEX_ZIP_FILE" ]; then
    echo "vortex installation zip file doesn't exist"
    exit 1
else
    unzip  -qq $VORTEX_ZIP_FILE -d $CATALINA_HOME/webapps/vortexweb
    ls -ls $CATALINA_HOME/webapps/vortexweb
fi

SRC_FILE=$DOTMATICS_LICENSE_FILE
FILE=dotmatics.license.txt
if [ -f "$SRC_FILE" ]; then
    mv -f $CATALINA_HOME/webapps/vortexweb/WEB-INF/$FILE $CATALINA_HOME/webapps/vortexweb/WEB-INF/${FILE}_backup || true
    ln -s $SRC_FILE $CATALINA_HOME/webapps/vortexweb/WEB-INF/$FILE
else
    echo "$SRC_FILE does not exist"
    exit 1
fi

chown -R tomcat:tomcat $CATALINA_HOME
chmod -R u-w  $CATALINA_HOME/conf
chmod -R u-w  $CATALINA_HOME/bin

ls -ls /usr/local/tomcat/webapps/vortexweb/

su -c "$CATALINA_HOME/bin/catalina.sh run" -s /bin/sh tomcat
