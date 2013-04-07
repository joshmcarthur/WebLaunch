#!/bin/sh

###############################################################################
## Configuration variables

APP_FOLDER="/mnt/us/extensions/WebLaunch"

SETTINGS_FILE="$APP_FOLDER/settings.cfg"

APPREG="/var/local/appreg.db"

APP_ID="com.PaulFreund.WebLaunch"
APP_ID_STRING="'$APP_ID'"

## WARNING - Changing the extension path after first run will result in errors,
## the following commands delete old keys from the app registry
# sqlite3 $APPREG "delete from handlerIds where handlerId=$APP_ID_STRING"
# sqlite3 $APPREG "delete from properties where handlerId=$APP_ID_STRING"

###############################################################################
## Register application if neccessary

#------------------------------------------------------------------------------
# Application Id
REG_ID=$(sqlite3 $APPREG "select handlerId from handlerIds where handlerId=$APP_ID_STRING")

if [[ -z "$REG_ID" ]]
then
	echo "Application Id not registered, registering..."
	sqlite3 $APPREG "INSERT INTO handlerIds VALUES ($APP_ID_STRING)"
fi

#------------------------------------------------------------------------------
# Application command
REG_COMMAND=$(sqlite3 $APPREG "select handlerId from properties where handlerId=$APP_ID_STRING and name='command'")

if [[ -z "$REG_COMMAND" ]]
then
	echo "Application command not registered, registering..."
	sqlite3 $APPREG "INSERT INTO properties (handlerId, name, value) VALUES ($APP_ID_STRING,'command','/usr/bin/mesquite -l $APP_ID -c $APP_FOLDER/bin/')"
fi

#------------------------------------------------------------------------------
# Application unloadPolicy
REG_UNLOADPOLICY=$(sqlite3 $APPREG "select handlerId from properties where handlerId=$APP_ID_STRING and name='unloadPolicy'")

if [[ -z "$REG_UNLOADPOLICY" ]]
then
	echo "Application unloadPolicy not registered, registering..."
	sqlite3 $APPREG "INSERT INTO properties (handlerId, name, value) VALUES ($APP_ID_STRING,'unloadPolicy','unloadOnPause')"
fi

###############################################################################
## Get the settings
SETTINGS=$(cat $SETTINGS_FILE)
SETTINGS=$(echo $SETTINGS | tr -d ' ')
SETTINGS=$(echo $SETTINGS | tr -d '\t')
SETTINGS=$(echo $SETTINGS | tr -d '\r')
SETTINGS=$(echo $SETTINGS | tr -d '\n')
#SETTINGS=$(echo $SETTINGS | sed 's/\"/A/g')
#SETTINGS=$(echo $SETTINGS | sed 's/{/A/g')
#SETTINGS=$(echo $SETTINGS | sed 's/}/A/g')
#SETTINGS=$(echo $SETTINGS | sed 's/\(..\)/%\1/g')

# I know this isnt nice, but time is rising
SETTINGS=$(echo $SETTINGS | sed 's/ /%20/g; s/!/%21/g; s/"/%22/g; s/#/%23/g; s/\$/%24/g; s/\&/%26/g; s/'\''/%27/g; s/(/%28/g; s/)/%29/g; s/:/%3A/g; s/{/%7B/g; s/}/%7D/g ; s/,/%2C/g ; s/\//%2F/g ' )                        

###############################################################################
## Start the application
lipc-set-prop com.lab126.appmgrd start app://$APP_ID?$SETTINGS