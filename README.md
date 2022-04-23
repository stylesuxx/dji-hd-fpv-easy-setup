# Post root setup

This is a collection of scripts aiming at helping you to get everything set up after rooting your DJI hardware.

> **DISCLAMIER:** Run at your own risk, I am not responsible if you brick your goggles. Nothing bad should happen if you follow all the directions.
> Further I have only tested this on the DJI HD FPV goggles V2. It should work the same on all other hardware though.

## Prerequisites
There are two things that you need to have set up [after you rooted your hardware](https://github.com/fpv-wtf/margerine):

1. [ADB](https://developer.android.com/studio/command-line/adb)
2. Internet connection sharing

### Internet connection sharing
In order for the goggles and air unit to communicate with the internet your PC has to share its connection with them. Depending on your OS there are different ways to do so.

#### Linux
On Linux you should see a new USB Ethernet network device popping up when attaching the goggles or air unit, you can verify this by running ifconfig with no hardware connected and then again with the hardware connected, it might look something like this:

```
enp3s0f0u4: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether fe:c4:22:af:83:d8  txqueuelen 1000  (Ethernet)
        RX packets 9  bytes 592 (592.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
For the sake of example my device with Internet connection is enp34s0.

On the Linux computer we now:

1. Create a bridge
2. Add devices to the bridge
3. Bring the bridge up

```
sudo ip addr flush dev enp34s0
sudo ip addr flush dev enp3s0f0u4
sudo brctl addbr br0
sudo brctl addif br0 enp34s0 enp3s0f0u4
sudo ip link set dev br0 up
```

#### Windows

#### MacOS

## Moving Files into place

Clone this repository or download the zip file and extract it.

* Download [busybox](https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-armv7l) to the `bin` directory.

Now use `adb` to move the file to the goggles or air unit:

```
adb push easy-setup /blackbox
```

## Setup

to start thesetup you need to connect to your goggles via `adb`:

```
adb shell
```

and then invoke the setup script:

```
cd /blackbox/easy-setup
./setup.sh
```

That is it - if everything went smoothly you will get a success message at the end. If the setup did not work out, check `debug.log` for more information.
