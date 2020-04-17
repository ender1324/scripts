#!/usr/bin/env bash
# This is a script that just clones trees from a devices org and builds the rom, pretty rom specific but you can easly modify it for your own needs

# Colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'

# Rom specific shit
repo="https://github.com/ProjectTitanium-devices"
defbranch="titanium-10"

mkdir ti
cd ti
echo "${grn}Created the rom directory $end"

# Syncing part
repo init -u https://github.com/Titanium-Wip/manifest.git -b titanium-10
repo sync --force-sync --no-tags --no-clone-bundle -j$(nproc --all)
echo "${grn}Synced the rom source $end"

# Cloning the device specific parts
read -p "Enter the oem (device brand) you need the trees for: " OEM 
if [ -z "$OEM" ]; then
echo "${red} This section cannot be empty $end"
exit 1
fi
read -p "Enter the device codename you need the trees for: " DEVICE 
if [ -z "$DEVICE" ]; then
echo "${red} This section cannot be empty $end"
exit 1
fi
read -p "Does your device have a common tree (Y/N): " DCOMM
read -p "Enter the device's soc name (eg. msm8953), leave blank if the device does not have common tree: " COMMON 
read -p "Enter the branch you need to clone (leave empty for default): " BRANCH
if [ -z "$BRANCH" ]; then
BRANCH="${defbranch}"
fi
echo "${grn} Cloning trees for $OEM $DEVICE $end"
echo "${grn} Cloning from branch $BRANCH $end"
read -p "Correct? (Y/N): " SURE
if [ "$SURE" != "Y" ] && [ "$SURE" != "y" ] && [ "$SURE" != "N" ] && [ "$SURE" != "n" ]; then
echo $SURE
echo "${red} Please enter Y or N $end";
exit 1
elif [ $SURE == N ] || [ $SURE == n ]; then
echo "${red} Aborting... $end"
exit 1
fi

if git clone ${repo}/android_device_${OEM}_${DEVICE} -b $BRANCH device/${OEM}/${DEVICE}; then echo "${grn} Successfully cloned device tree $end"; else echo "${red} Failed cloning device tree $end"; fi
if [ "$DCOMM" == "Y" ] || [ "$DCOMM" == "y" ]; then
if git clone ${repo}/android_device_${OEM}_${COMMON}-common -b $BRANCH device/${OEM}/${COMMON}-common; then echo "${grn} Successfully cloned common tree $end"; else echo "${red} Failed cloning common tree $end>
fi
fi
# i was pretty lazy here, so just deny if its everything but Y/y
if [ "$DCOMM" != "Y" ] && [ "$DCOMM" != "y" ]; then
echo Device does not have common tree, skipping
fi
if git clone ${repo}/android_kernel_${OEM}_${COMMON} -b $BRANCH kernel/${OEM}/${COMMON}; then echo "${grn} Successfully cloned kernel tree $end"; else echo "${red} Failed cloning kernel tree $end"; fi
if git clone ${repo}/vendor_${OEM}_${COMMON} -b $BRANCH vendor/${OEM}/${COMMON}; then echo "${grn} Successfully cloned vendor tree $end"; else echo "${red} Failed cloning vendor tree $end"; fi

# Building part
echo "${blu}Starting build and all done, enjoy the meme $end"
. build/envsetup.sh
brunch vince
