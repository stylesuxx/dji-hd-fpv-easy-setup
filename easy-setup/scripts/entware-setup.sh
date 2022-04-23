#!/system/bin/sh
ENTWARE_PATH=$1

# Only attempt mounting if /opt does not exist.
# If it exists, entware has probably already been mounted before.
if [ ! -e "/opt" ]
then
  mount -o rw,remount /
  mkdir /bin
  ln -s /system/bin/sh /bin/sh
  ln -s $ENTWARE_PATH /opt
  mount -o ro,remount /
fi
