#!/bin/sh 

set -e

CI_DIR=$(dirname $0)
. $CI_DIR/config.sh
. $CI_DIR/utils.sh

APP_NAME=$(get_app_name "${APP_NAME:-}")
SITE_NAME=$(get_app_site "${APP_SITE:-}")
VERSION=$(get_app_version "${VERSION:-}")

if [ -z $DEPLOY_USER ]; then
  echo "Error: DEPLOY_USER is not set in config.sh"
  exit 1
fi

if [ -z $WEB_HOST ]; then
  echo "Error: WEB_HOST is not set in config.sh"
  exit 1
fi

ENVIRONMENT=${ENVIRONMENT:-development}
echo "Using environment: ${ENVIRONMENT}"

if [ -z "$WEB_PROJECTS" ]; then
  echo "No WEB_PROJECTS set; skipping web deploy."
  exit 0
fi

echo "Deploying web archive for '$APP_NAME:$VERSION'..."
ssh $SSH_ARGS $DEPLOY_USER@$WEB_HOST <<EOF
cd $SITE_NAME

WEB_ARCHIVE="../staging/${APP_NAME}-web-${VERSION}.tgz"
if [ ! -f "\$WEB_ARCHIVE" ]; then
  echo "Web archive \$WEB_ARCHIVE not found"
  exit 1
fi

mkdir -p backups
mkdir -p wwwroot.new
tar -xzvf "\$WEB_ARCHIVE" -C wwwroot.new

if [ -d wwwroot ]; then
  mv wwwroot backups/wwwroot-$(date +%Y%m%d%H%M%S)
fi
mv wwwroot.new wwwroot

EOF
