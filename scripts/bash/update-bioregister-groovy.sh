#!/bin/sh

if [ ! -z "$1" ] &&  [ "$1" = "debug" ] ; then
    set -x
    set -e
fi

### This script is used by download.sh and userdata.sh
export TMP_BIOREGISTER_WAR_FILE=$(ls $TMP_CONFIG_DIR/bioregister-*)
export TMP_BIOREGISTER_WAR_COUNT=$(ls $TMP_CONFIG_DIR/bioregister-* | wc -l | xargs )


aws s3 cp s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/bioregister.groovy   $TMP_CONFIG_DIR/  || true

if [ -z "$TMP_BIOREGISTER_WAR_FILE" ]; then
    echo "[WARN] There is no bioregister installation zip file."

elif [ "$TMP_BIOREGISTER_WAR_COUNT" -gt 1 ] ; then
    echo "[ERROR] Too many bioregister installation zip files."
    exit 1

else
  if [  -f "$TMP_BIOREGISTER_GROOVY" ]; then

        echo -e "\nFound war file and new bioregister.groovy, updating serverURL, DB url and password ..."

        if [   -f  "$EFS_BIOREGISTER_GROOVY" ]; then
            export BIOREGISTER_PASSWORD=$(cat $EFS_BIOREGISTER_GROOVY | grep password= |  cut -d"'" -f2 | xargs)
            sed -i 's/password=\x27.*\x27/password=\x27'$BIOREGISTER_PASSWORD'\x27/g' $TMP_BIOREGISTER_GROOVY

            export ENCRYPT_CODE=$(cat $TMP_BIOREGISTER_GROOVY | grep passwordEncryptionCodec=)
            if [ -z "$ENCRYPT_CODE" ]; then
                echo "Not found passwordEncryptionCodec in new bioregister.groovy, attaching it to bioregiser.groovy"
                sed -i '/password=\x27.*\x27/ a \\tpasswordEncryptionCodec=BrowserEncryptionCodec' $TMP_BIOREGISTER_GROOVY
            fi

        else
            echo "bioregister.groovy not found in EFS, it is first time deploying bioregister."
        fi

        sed -i 's/http:\/\/localhost:8080/'$APP_SERVER_URL'/g'  $TMP_BIOREGISTER_GROOVY
        sed -i 's/localhost/'$PRIVATE_DNS_NAME'/g'  $TMP_BIOREGISTER_GROOVY
        sed -i 's/c:\\\\c2c_attachments/\/c2c_attachments/g' $TMP_BIOREGISTER_GROOVY
        sed -i 's/XE/'$P_DATABASE_NAME'/g' $TMP_BIOREGISTER_GROOVY

        if [ -z "$BACKUP_DATE" ]; then
            export BACKUP_DATE=$(date +'%Y-%m%d-%Hh%M')
        fi

        if [  -f "$EFS_BIOREGISTER_GROOVY" ]; then
            mkdir -p /efs/backup/$BACKUP_DATE/
            cp -r $EFS_BIOREGISTER_GROOVY /efs/backup/$BACKUP_DATE/
        fi

       export BIOREGISTER_CONTAINER_ID=$( docker ps --filter label=app.name=bioregister --format {{.ID}} )

       if [ ! -z "$BIOREGISTER_CONTAINER_ID" ]; then
            echo "Found running bioregister container."
            echo "Moving new bioregister.groovy to bioregister container ... "
            docker cp $TMP_BIOREGISTER_GROOVY $BIOREGISTER_CONTAINER_ID:/tmp/
            docker exec -t $BIOREGISTER_CONTAINER_ID bash -c 'cat /tmp/bioregister.groovy > /symbolic_link/bioregister.groovy'

            echo -e "\n[Result]"
            echo "bioreigster.groovy has been updated."
            echo "Previous bioregister.groovy: /efs/backup/$BACKUP_DATE/bioregister.groovy"
            echo "New bioregister.groovy: $EFS_BIOREGISTER_GROOVY"
       else
            echo "There is no running bioregister container."
            yes | mv $TMP_BIOREGISTER_GROOVY $EFS_BIOREGISTER_GROOVY
       fi




  else
      echo "[ERROR] Bioregister installation zip file exists, but $TMP_BIOREGISTER_GROOVY doesn't exist"
      exit 1
  fi
fi




