#!/system/bin/sh
BASE_PATH="/blackbox/entware"
DINIT_PATH="/opt/bin/dinit"

# Setup entware environment
"${BASE_PATH}/bin/entware-setup.sh" $BASE_PATH
PATH=/opt/bin/:/opt/sbin/:$PATH

# If /opt exists, attempt to  start dinit
if [ -e "$DINIT_PATH" ]
then
  # Start dinit
  dinit -q -u -d /opt/etc/dinit.d &
else
  echo "Error: dinit not available"
fi
