#!/bin/bash
#set -x

ERROR_PRIV=65
ERROR_NGINX_NOT_INSTALL=67

NGINX_DIR=/etc/nginx/conf.d
SERV_CONFIG=/etc/nginx/conf.d/default.conf
NDAY=$(date +%F)


if [ $UID -ne 0 ]
        then
                echo "Need root privileges (use sudo)"
                exit $ERROR_PRIV
fi

if [ ! -d $NGINX_DIR ]
	then
		echo " $NGINX_DIR not exist, check or install nginx"
		exit $ERROR_NGINX_NOT_INSTALL
fi

cd $NGINX_DIR

if [ -f $SERV_CONFIG ]
        then
                mv $SERV_CONFIG $SERV_CONFIG-$NDAY.bac
                echo "Making backup previous config. $SERV_CONFIG-$NDAY.bac exist"
fi

Check installing git and check can we install new repo without git init

if [ ! -d $NGINX_DIR/.git ]
	then
		git clone git@github.com:IVyacheslavA/otus-nginx.git
fi


