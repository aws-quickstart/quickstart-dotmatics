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
BROWSER_ZIP_FILE=$(ls /config/tmp/browser-*.zip )
BROWSER_ZIP_COUNT=$(ls /config/tmp/browser-*.zip | wc -l | xargs )

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

declare -a arr=("browser.properties"
                "dotmatics.license.txt"
                "columntypes.tx_"
                "columntypes.txt"
                "sso.adfs.template.xml"
                "sso.centrify.template.xml"
                "sso.generic.demo.metadata.xml"
                "sso.generic.template.xml"
                "sso.okta.template.xml"
                "sso.okta.test.metadata.xml"
                "sso.properties"
                "filterpaths.txt"
                "sessionclasses.txt"
                "toolpainters.txt"
                )

## now loop through the above array
for FILE in "${arr[@]}"
do
   echo "Checking $FILE ..."
    if [ !  -f "/config/WEB-INF/$FILE" ]; then
        echo "Creating empty file /config/WEB-INF/$FILE"
        touch /config/WEB-INF/$FILE
        chown tomcat:tomcat /config/WEB-INF/$FILE
        chmod 644 /config/WEB-INF/$FILE
    fi

    echo "Using existing file in EFS /config/WEB-INF/$FILE"
    mv -f $CATALINA_HOME/webapps/browser/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/${FILE}_backup || true
    ln -s /config/WEB-INF/$FILE $CATALINA_HOME/webapps/browser/WEB-INF/$FILE

done


chown -R tomcat:tomcat $CATALINA_HOME
chmod -R u-w  $CATALINA_HOME/conf
chmod -R u-w  $CATALINA_HOME/bin

chmod 755  /usr/local/tomcat/webapps/browser/pdf
chmod 755  /usr/local/tomcat/webapps/browser/tempfiles
chmod 755  /usr/local/tomcat/webapps/browser/images/profiles

find /usr/local/tomcat/webapps/browser/ -name "raw data" -type d | xargs -I {} chmod -R 755 "{}"
ls -ls /usr/local/tomcat/webapps/browser/

su -c "$CATALINA_HOME/bin/catalina.sh run" -s /bin/sh tomcat
