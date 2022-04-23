#!/system/bin/sh
BLACKBOX_PATH="/blackbox"
BASE_PATH="${BLACKBOX_PATH}/easy-setup"

DEBUG_PATH="${BASE_PATH}/debug.log"
BUSYBOX_PATH="${BASE_PATH}/bin/busybox-armv7l"

SCRIPT_PATH="${BASE_PATH}/scripts"
ENTWARE_SETUP_PATH="${SCRIPT_PATH}/entware-setup.sh"
AUTOSTART_PATH="${SCRIPT_PATH}/autostart.sh"

ENTWARE_PATH="${BLACKBOX_PATH}/entware"

# Nameserver that should be used
IP_NAMESERVER="1.1.1.1"

RNDIS_DEVICE="rndis0"

WGET_PATH="/system/bin/wget"
PING_PATH="/system/bin/ping"
VI_PATH="/system/bin/vi"
RESOLV_PATH="/etc/resolv.conf"

# Resources for testing internet conectivity
PING_COUNT=2
IP_ADDRESS="1.1.1.1"
DOMAIN="google.com"

# URLs for resources that will be fetched during setup
ENTWARE_URL="http://bin.entware.net/armv7sf-k3.2/installer/alternative.sh"
DINIT_URL="https://github.com/stylesuxx/dji-hd-fpv-dinit/releases/download/v0.1.0/dinit_0.14.0pre_armv7-3.2.ipk"

debugAndExit() {
  echo "For more information check ${DEBUG_PATH}"
  exit 1
}

verifyPrerequesits() {
  # Link needed busybox functionality
  linkBusyBox() {
    echo " - Checking busybox links..."
    chmod +x $BUSYBOX_PATH

    if [ ! -f "$WGET_PATH" ]
    then
      echo "  - Linking wget..."
      ln -s $BUSYBOX_PATH $WGET_PATH
    fi

    if [ ! -f "$PING_PATH" ]
    then
      echo "  - Linking ping..."
      ln -s $BUSYBOX_PATH $PING_PATH
    fi

    if [ ! -f "$VI_PATH" ]
    then
      echo "  - Linking vi..."
      ln -s $BUSYBOX_PATH $VI_PATH
    fi
  }

  pingIp() {
    echo " - Checking internet connection..."
    $PING_PATH -c${PING_COUNT} $IP_ADDRESS >> $DEBUG_PATH 2>&1
  }

  pingDomain() {
    echo " - Checking name resolution..."
    $PING_PATH -c${PING_COUNT} $DOMAIN >> $DEBUG_PATH 2>&1
  }

  checkNameserver() {
    echo " - Checking for nameserver"
    grep "nameserver" $RESOLV_PATH >> $DEBUG_PATH 2>&1
  }

  configureNameserver() {
    echo " - Configure nameserver"
    echo "nameserver ${IP_NAMESERVER}" >> $RESOLV_PATH
  }

  setupRNDIS() {
    dhcptool ${RNDIS_DEVICE}
  }

  # Clear debug log
  rm -f DEBUG_PATH

  # Check that patched busybox is available
  if [ ! -f "$BUSYBOX_PATH" ]
  then
    echo "ERROR: $BUSYBOX_PATH does not exist, pleas use adb to move in place"
    debugAndExit
  fi

  linkBusyBox

  setupRNDIS
  pingIp
  if [ $? -ne 0 ]
  then
    echo "ERROR: Could not ping ${IP_ADDRESS}"
    echo "Make sure that the hosts internet connection is shared with this device"
    debugAndExit
  fi

  checkNameserver
  if [ $? -ne 0 ]
  then

    configureNameserver
    if [ $? -ne 0 ]
    then
      echo "ERROR: Could not configure nameserver"
      debugAndExit
    fi
  fi

  pingDomain
  if [ $? -ne 0 ]
  then
    echo "ERROR: Could not resolve ${DOMAIN}"
    echo "Check DNS server(${IP_NAMESERVER})"
    debugAndExit
  fi
}

echo "Validating prerequesits:"
verifyPrerequesits

echo "Preparing entware environment:"
if [ ! -d "$ENTWARE_PATH" ]
then
  echo "  - Creating entware base directory..."
  mkdir $ENTWARE_PATH >> $DEBUG_PATH 2>&1

  if [ $? -ne 0 ]
  then
    echo "ERROR: Could not create enware base directory({$ENTWARE_PATH})"
    debugAndExit
  fi
fi

# Remount everything to be ready for entware
echo " - Setting up entware environment..."
$ENTWARE_SETUP_PATH $ENTWARE_PATH >> $DEBUG_PATH 2>&1

# Install entware if directory is empty
if [ "$(ls $ENTWARE_PATH) | wc -l" = 0 ]
then
  echo "  - Installing entware..."
  wget -q -O - ${ENTWARE_URL} | sh >> $DEBUG_PATH 2>&1
fi

PATH="/opt/bin:/opt/sbin:$PATH"

# Update repository
echo "  - Updating entware repository..."
opkg update >> $DEBUG_PATH 2>&1

echo "Installing packages:"
echo " - wget-ssl"
opkg install wget-ssl >> $DEBUG_PATH 2>&1

echo " - dinit..."
wget-ssl --no-check-certificate -q -P ./ipk ${DINIT_URL}
opkg install ./ipk/dinit_*.ipk >> $DEBUG_PATH 2>&1
if [ $? -ne 0 ]
then
  echo "ERROR: Failed installing dinit"
  debugAndExit
fi

# Move autostart file in place and execute it as last script during startup
cp $SCRIPT_PATH/* "${ENTWARE_PATH}/bin/"
if [ $? -ne 0 ]
then
  echo "ERROR: Failed copying files"
  debugAndExit
fi

echo ""
echo "========="
echo "All done!"
echo "========="
echo "Expand your path to include entware bin direcotries:"
echo "PATH=/opt/bin:/opt/sbin:\$PATH"
