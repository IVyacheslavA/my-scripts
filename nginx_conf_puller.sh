#!/bin/bash
#set -x

ERROR_PRIV=65
ERROR_NGINX_NOT_INSTALL=67
ERROR_GIT_NOT_INIT=68
ERROR_GIT_NOT_INSTALL=69
ERROR_INCOR_CONFIG=70
ERROR_FATAL=71


NGINX_DIR=/etc/nginx/conf.d
SERV_CONFIG=/etc/nginx/conf.d/default.conf
NDAY=$(date +%F)
RAND_NUMBER=$(sudo < /dev/urandom tr -dc A-Za-z0-9 | head -c10)


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

CHECK_REMOTE=$(sudo git remote -v | echo $?)

if [ -f $SERV_CONFIG ]
        then
                mkdir -p config_bac
		cp $SERV_CONFIG ./config_bac/config-$NDAY-$RAND_NUMBER.bac
                echo "Making backup previous config. config-$NDAY-$RAND_NUMBER.bac is done"
fi

if [ $(git --version | echo $?) -ne 0 ]
	then
		echo "Git not installed"
		exit $ERROR_GIT_NOT_INSTALL
fi
		

if [ ! -d $NGINX_DIR/.git ]
	then
		git clone git@github.com:IVyacheslavA/otus-nginx.git
	elif [ $CHECK_REMOTE -ne 0 ]
		then
			git remote add origin git@github.com:IVyacheslavA/otus-nginx.git
			git pull
	else
		git pull
fi

if [ $? -ne 0 ]
	then
		echo "Something went wrong... can't pull repo from github"
		exit $ERROR_FATAL
fi

if [ $(nginx -t | echo $?) -ne 0 ]
	then
		echo "New config is not correct. Placed in the incorrect_config"
		mv $SERV_CONFIG ./incorrect_config
		cp ./config_bac/config-$NDAY-$RAND_NUMBER.bac $SERV_CONFIG
		echo "Old config file is return"
		exit $ERROR_INCOR_CONFIG
fi

systemctl reload nginx








