#!/bin/bash

# Enable/disable Do-not-Disturb feature for a Vonage phone
# Inspired by/copied from
# http://www.linuxjournal.com/content/use-curl-monitor-your-vonage-phone-bill

# Prevent other users from reading our temp files
umask u=rw,go=

cookie_jar=/tmp/vonage_dnd_cookies.tmp
web_page=/tmp/vonage_dnd.tmp
USERNAME=myusername
PASSWORD=XXXXX
PHONE_NUMBER=12127329864 # 10-digit phone number

if [ "x$1" == "x" ] ; then
	echo Usage: $0 'on|off'
	exit 1
fi

if [ "x$1" == "xon" ] ; then
	VALUE=true
elif [ "x$1" == "xoff" ] ; then
	VALUE=false
else
	echo Usage: $0 'on|off'
	exit 1
fi

trap "rm -f $cookie_jar $web_page-*" EXIT

echo Opening login page
curl --silent --cookie-jar $cookie_jar \
	--output $web_page-1 \
	http://www.vonage.com/?login

echo Logging in
curl --silent --cookie $cookie_jar --cookie-jar $cookie_jar \
	--location \
	--data "username=$USERNAME&password=$PASSWORD" \
	--output $web_page-2 \
	https://secure.vonage.com/vonage-web/public/login.htm

#curl --silent --cookie $cookie_jar --cookie-jar $cookie_jar \
#    --output $web_page-3 \
#    https://secure.vonage.com/webaccount/billing/index.htm
#
#echo
#echo
#echo Phone bill: $(grep -A 1 'td_value_total_amount' $web_page-3 | tail -1)

echo Turning $1 DnD
curl --silent --cookie $cookie_jar --cookie-jar $cookie_jar \
	--output $web_page-4 \
	--data "on=$VALUE&phoneNumber=$PHONE_NUMBER" \
	https://secure.vonage.com/webaccount/features/DoNotDisturb/edit.htm

echo Logging off
curl --silent --cookie $cookie_jar --cookie-jar $cookie_jar \
	--location \
	--output $web_page-5 \
	https://secure.vonage.com/webaccount/public/logoff.htm

