#!/bin/sh
# ------------------------------------------------------------------
# [Lucas Ko]
#
# Download and update bioregister.groovy
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=download-bioregister
SCRIPT_UPDATE_BIOREGISTER_GROOVY=/project/quickstart-dotmatics/scripts/bash/update-bioregister-groovy.sh

USAGE=$(cat  << EOF
Usage:	download [SERVICES] \n\n

It is going to download bioregister.groovy and apply it to running container. \n
This script will not download and redeploy bioregister war file. \n\n
Servics: \n
\tbioregister -   download bioregister.groovy from S3 to running container \n
\tsso         -   download sso files from S3 to webapps/browser/WEB-INF/ in running container \n
\timages      -   download image files from S3 to webapps/browser/images/ in running container \n

EOF
)



# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    echo -e $USAGE
    exit 1;
fi

while getopts ":i:vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "i")
        echo "-i argument: $OPTARG"
        ;;
      "h")
        echo -e $USAGE
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

param1=$1

# --- Locks -------------------------------------------------------
LOCK_FILE=/tmp/$SUBJECT.lock
if [ -f "$LOCK_FILE" ]; then
   echo "Script is already running"
   exit
fi

trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE


# --- Functions --------------------------------------------------------
function download_bioregister_groovy(){

    echo "Update Bioregister Groovy:"
    $SCRIPT_UPDATE_BIOREGISTER_GROOVY
}

function download_sso_files(){
    echo "Downloading sso files from S3 to browser container ..."
    aws s3 ls s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/browser/WEB-INF/
    aws s3 sync  s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/browser/WEB-INF/ $EFS_CUSTOMED_BROWSER_DIR/WEB-INF/ --exclude "*.*" --include "sso.*"
    chown -R 1000:1000 $EFS_CUSTOMED_BROWSER_DIR/WEB-INF/
    export BROWSER_CONTAINER_ID=$( docker ps --filter label=app.name=browser --format {{.ID}} )
    FILES=$EFS_CUSTOMED_BROWSER_DIR/WEB-INF/sso.*

    for f in $FILES
    do
      if [   -f "$f" ]; then
          echo "Processing $f file..."
          docker cp $f $BROWSER_CONTAINER_ID:/usr/local/tomcat/webapps/browser/WEB-INF/
          docker exec -t $BROWSER_CONTAINER_ID chown -R 1000:1000 /usr/local/tomcat/webapps/browser/WEB-INF/
      fi
    done

    echo -e "\ndownload_sso_files done"
}


function download_image_files(){
    echo "Downloading image files from S3 to browser container ..."
    aws s3 ls s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/browser/images/
    aws s3 sync  s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/browser/images/ $EFS_CUSTOMED_BROWSER_DIR/images/  --include "*.*"
    chown -R 1000:1000 $EFS_CUSTOMED_BROWSER_DIR/images/
    export BROWSER_CONTAINER_ID=$( docker ps --filter label=app.name=browser --format {{.ID}} )
    FILES=$EFS_CUSTOMED_BROWSER_DIR/images/*

    for f in $FILES
    do
      if [   -f "$f" ]; then
          echo "Processing $f file..."
          docker cp $f $BROWSER_CONTAINER_ID:/usr/local/tomcat/webapps/browser/images/
          docker exec -t $BROWSER_CONTAINER_ID chown -R 1000:1000 /usr/local/tomcat/webapps/browser/images/
      fi
    done

    echo -e "\ndownload_image_files done"
}

function check_env_configuration(){

if [ -z "$P_INSTALL_BUCKET_NAME" ]; then
    echo "[ERROR] P_INSTALL_BUCKET_NAME env variable cannot be empty."
    exit 0 ;

elif [ -z "$P_INSTALL_BUCKET_PREFIX" ]; then
    echo "[ERROR] P_INSTALL_BUCKET_PREFIX env variable cannot be empty."
    exit 0 ;

elif [ -z "$EFS_BIOREGISTER_GROOVY" ]; then
    echo "[ERROR] EFS_BIOREGISTER_GROOVY env variable cannot be empty."
    exit 0 ;

elif [ -z "$APP_SERVER_URL" ]; then
    echo "[ERROR] APP_SERVER_URL env variable cannot be empty."
    exit 0 ;

elif [ -z "$PRIVATE_DNS_NAME" ]; then
    echo "[ERROR] PRIVATE_DNS_NAME env variable cannot be empty."
    exit 0 ;

elif [ -z "$P_DATABASE_NAME" ]; then
    echo "[ERROR] P_DATABASE_NAME env variable cannot be empty."
    exit 0 ;

elif [ -z "$EFS_CUSTOMED_BROWSER_DIR" ]; then
    echo "[ERROR] EFS_CUSTOMED_BROWSER_DIR env variable cannot be empty."
    exit 0 ;





elif [ ! -f "$SCRIPT_UPDATE_BIOREGISTER_GROOVY" ]; then
    echo "[ERROR] $SCRIPT_UPDATE_BIOREGISTER_GROOVY not found, please contact administrator"
    exit 0 ;


fi

}


# --- Body --------------------------------------------------------

check_env_configuration

#  SCRIPT LOGIC GOES HERE
#echo param1=$param1


if [ "bioregister" = $param1 ]; then
   download_bioregister_groovy

elif [ "sso" = $param1 ]; then
    download_sso_files


elif [ "images" = $param1 ]; then
    download_image_files

else
    echo "invalid service '$param1'"
    exit 0;
fi


# -----------------------------------------------------------------
