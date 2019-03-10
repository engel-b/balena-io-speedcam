#!/bin/sh

# set timezone with TZ (eg. TZ=EUROPE/Berlin)
if [ -n "${SSH_PUBLIC_KEY}" ]
then
  mkdir -p ~/.ssh
  chmod 600 ~/.ssh
  cat ${SSH_PUBLIC_KEY} >  ~/.ssh/authorized_keys
fi

# set timezone with TZ (eg. TZ=EUROPE/Berlin)
if [ -n "${TZ}" ]
then
	ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
	echo "${TZ}" > /etc/timezone
fi
