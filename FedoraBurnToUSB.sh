#!/bin/bash

#create new working directory
mkdir FedoraWorkstation
cd FedoraWorkstation

#get the .iso file and ask spin from user

function chooseFedoraType(){

  echo "Pick the spin for Fedora:"
  echo "Fedora Workstation --------- 0"
  echo "Fedora KDE ----------------- 1"
  echo "Fedora XFCE ---------------- 2"
  echo "Fedora LXQT ---------------- 3"
  echo "Fedora MATE-Compiz --------- 4"
  echo "Fedora Cinnamon ------------ 5"
  echo "Fedora LXDE ---------------- 6" 
  echo "Fedora SoaS ---------------- 7"

  fedoraVersions=("Workstation-Live-x86_64-31-1.9.iso" "KDE-Live-x86_64-31-1.9.iso" "Xfce-Live-x86_64-31-1.9.iso " "LXQt-Live-x86_64-31-1.9.iso" "MATE_Compiz-Live-x86_64-31-1.9.iso" "Cinnamon-Live-x86_64-31-1.9.iso" "LXDE-Live-x86_64-31-1.9.iso" "SoaS-Live-x86_64-31-1.9.iso")

  read spinType
  if [ "$spinType" == 0 ]; then
    versionDownload="https://download.fedoraproject.org/pub/fedora/linux/releases/31/Workstation/x86_64/iso/Fedora-"
    wget https://getfedora.org/static/checksums/Fedora-Workstation-31-1.9-x86_64-CHECKSUM
  elif [ "$spinType" > 0 ]; then
    if [ $(("$spinType" < 8)) ]; then
      versionDownload="https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-"
      wget http://fedora.mirror.angkasa.id/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-Spins-31-1.9-x86_64-CHECKSUM
    fi
  else 
    echo "Incorrect input."
    exit
  fi

  echo ""

  versionDownload="$versionDownload${fedoraVersions["$spinType"]}"
  
  echo "$versionDownload"

  wget $versionDownload
  echo ".iso installed successfully."
 
}

checksumCheck(){
  curl https://getfedora.org/static/fedora.gpg | gpg --import
  gpg --verify-files *-CHECKSUM
  verify=$(sha256sum -c *-CHECKSUM)
  
  if [[ "$verify" != *": OK"* ]]; then
    echo "Incorrect Checksum."
    exit
  fi

  echo ""
  echo "Checksum Valid."
}

getUSBDir(){
  sudo blkid

  while true
  do
    echo "Type the directory your USB device is in e.g. /dev/sdb1."
    read usbDir
  
    if [[ "$usbDir" == *"/dev/sd"* ]]; then
      echo "Good Directory."
      break
    fi
 
    echo "Invalid Directory."
  done

}

formatUSB(){
  echo "Burning to drive (Normal) ..."
  sudo umount $usbDir
  sudo dd bs=8M if=$isoFile of=$usbDir oflag=direct  status=progress
  echo "Success!"
}

formatUSBFAT32(){
  sudo umount $usbDir

  usbDir=$(udisksctl mount -b $usbDir)
  usbDir=$(echo $usbDir | cut -d'.' -f 1)
  usbDir=${usbDir:21}

  echo "This may take a while. Do not shut down the program until the success message appears."

  cp "$isoFile" "$usbDir"

  echo "Success!"
}



echo "-----------------------------------"
echo "Fedora Downloader and Burner to USB"
echo "-----------------------------------"
echo ""

#download and install fedora

chooseFedoraType

isoFile=(*.iso)



#get and verify the checksums

echo ""

echo "--------------------------"

echo "Starting checksum check..."

echo ""

checksumCheck

#finds attached USB devices
echo ""
echo "--------------------------"
echo "Finding USB device..."
echo ""
usbDir=""

getUSBDir

#burns .iso file to USB
#check UEFI support
echo "--------------------------"
echo ""
while true
do
  echo "Does your system support UEFI? (If you select y, the script will format the USB in FAT32, this has the advantage of not destroying your USB)"  
  echo "y/n"
  read typeBurn 
  if [ "$typeBurn" == "y" ]; then
    echo "Burning to drive (FAT32) ..."
    formatUSBFAT32
    exit
  fi
  if [ "$typeBurn" == "n" ]; then
    formatUSB
    exit
  fi
  echo "Incorrect option"
done
