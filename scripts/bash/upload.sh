#!/bin/sh
# ------------------------------------------------------------------
# [Lucas Ko]
#
# Upload bioregister.groovy and browser.properties to S3
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=backup-properties-files


USAGE=$(cat  << EOF
Usage:	upload [SERVICES] \n\n
Obtain current files from running containers,then upload to AWS S3 bucket. The destination will be in the directory of installation binary files. \n\n

Servics: \n
\tall           \t\t  upload browser.properties and bioregister.groovy to S3 \n
\tbrowser       \t    upload browser.properties to S3 \n
\tbioregister   \t    upload bioregister.groovy to S3 if file exists\n

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


# --- Function --------------------------------------------------------
function upload_browser_properties(){

    if [ -f "$EFS_BROWSER_PROPERTIES" ] ; then
        aws s3 cp $EFS_BROWSER_PROPERTIES  s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/browser.properties
    else
        echo -e "$EFS_BROWSER_PROPERTIES not found"
        exit 0;
    fi
}

function upload_bioregister_groovy(){

    if [ -f "$EFS_BIOREGISTER_GROOVY" ] ; then
        aws s3 cp $EFS_BIOREGISTER_GROOVY  s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/bioregister.groovy
    else
        echo -e "$EFS_BIOREGISTER_GROOVY not found"
        exit 0;
    fi
}


function backup(){

echo "
Doing backup for browser.properties and bioregister.groovy in AWS S3"

export BACKUP_DATE=$(date +'%Y-%m%d-%Hh%M')
aws s3 cp s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/bioregister.groovy  s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/backup/$BACKUP_DATE/ || true
aws s3 cp s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/browser.properties  s3://$P_INSTALL_BUCKET_NAME/$P_INSTALL_BUCKET_PREFIX/backup/$BACKUP_DATE/ || true

echo -e "\n"
}

function check_env_configuration(){

if [ -z "$P_INSTALL_BUCKET_NAME" ]; then
    echo "[ERROR] P_INSTALL_BUCKET_NAME env variable is empty, please specify a bucket name"
    exit 0 ;

elif [ -z "$P_INSTALL_BUCKET_PREFIX" ]; then
    echo "[ERROR] P_INSTALL_BUCKET_PREFIX env variable is empty, please specify a prefix key"
    exit 0 ;

elif [ -z "$EFS_BROWSER_PROPERTIES" ]; then
    echo "[ERROR] EFS_BROWSER_PROPERTIES env variable is empty, please specify a path of browser.properties"
    exit 0 ;


elif [ -z "$EFS_BIOREGISTER_GROOVY" ]; then
    echo "[ERROR] EFS_BIOREGISTER_GROOVY env variable is empty, please specify a path of bioregister.groovy"
    exit 0 ;

fi

}


# --- Body --------------------------------------------------------

check_env_configuration

#  SCRIPT LOGIC GOES HERE
#echo param1=$param1




echo "Uploading files to AWS S3 ..."

if [ "browser" = $param1 ]; then
    backup
    upload_browser_properties

elif [ "bioregister" = $param1 ]; then
    backup
    upload_bioregister_groovy

elif [ "all" = $param1 ]; then
    backup
    upload_browser_properties
    upload_bioregister_groovy
else
    echo "invalid service '$param1'"
    exit 0;
fi


# -----------------------------------------------------------------
