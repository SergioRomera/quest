#! /bin/sh

cd /etc/init.d

\cp /home/foglight/Quest/Foglight/scripts/init.d/RedHat/* /etc/init.d/.

sed -i -e 's/@@FOGLIGHT_HOME_PATH@@/\/home\/foglight\/Quest\/Foglight/g' /etc/init.d/foglight
sed -i -e 's/@@FOGLIGHT_HOME_PATH@@/\/home\/foglight\/Quest\/Foglight/g' /etc/init.d/foglight-FMS

sed -i -e 's/$FOGLIGHT_START/su - foglight -c "rm -f \/home\/foglight\/Quest\/Foglight\/state\/.Fog* \&\& $FOGLIGHT_START"/g' /etc/init.d/foglight
sed -i -e 's/$FOGLIGHT_STOP/su - foglight -c "$FOGLIGHT_STOP"/g' /etc/init.d/foglight
sed -i -e 's/$0 stop/su - foglight -c "$0 stop"/g' /etc/init.d/foglight
sed -i -e 's/$0 start/su - foglight -c "rm -f \/home\/foglight\/Quest\/Foglight\/state\/.Fog* \&\& $0 start"/g' /etc/init.d/foglight

sed -i -e 's/$FOGLIGHT_START/su - foglight -c "rm -f \/home\/foglight\/Quest\/Foglight\/state\/.Fog* \&\& $FOGLIGHT_START"/g' /etc/init.d/foglight-FMS
sed -i -e 's/$FOGLIGHT_STOP/su - foglight -c "$FOGLIGHT_STOP"/g' /etc/init.d/foglight-FMS
sed -i -e 's/$0 stop/su - foglight -c "$0 stop"/g' /etc/init.d/foglight-FMS
sed -i -e 's/$0 start/su - foglight -c "rm -f \/home\/foglight\/Quest\/Foglight\/state\/.Fog* \&\& $0 start"/g' /etc/init.d/foglight-FMS

#chkconfig --del foglight-FMS
chkconfig --add foglight-FMS
