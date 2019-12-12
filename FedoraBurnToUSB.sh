#!/bin/bash

#create new working directory
mkdir FedoraWorkstation
cd FedoraWorkstation


echo "-----------------------------------"
echo "Fedora Downloader and Burner to USB"
echo "-----------------------------------"
echo ""
#get the .iso file and ask spin from user

echo "As of now the checksum checks for the Fedora Spins do not work so to save time just select 0"

echo "Pick the spin for Fedora:"
echo "Fedora Workstation --------- 0"
echo "Fedora KDE ----------------- 1"
echo "Fedora XFCE ---------------- 2"
echo "Fedora LXQT ---------------- 3"
echo "Fedora MATE-Compiz --------- 4"
echo "Fedora Cinnamon ------------ 5"
echo "Fedora LXDE ---------------- 6"
echo "Fedora SoaS ---------------- 7"

read spinType

if [ "$spinType" == "0" ]; then
  echo "Installing Fedora Workstation ..."
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-31-1.9.iso
  wget https://getfedora.org/static/checksums/Fedora-Workstation-31-1.9-x86_64-CHECKSUM
elif [ "$spinType" == "1" ]; then
  echo "Installing Fedora KDE ..."
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-KDE-Live-x86_64-31-1.9.iso
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
elif [ "$spinType" == "2" ]; then
  echo "Installing Fedora XFCE"
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-Xfce-Live-x86_64-31-1.9.iso 
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
elif [ "$spinType" == "3" ]; then
  echo "Installing Fedora LXQT"
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-LXQt-Live-x86_64-31-1.9.iso
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
elif [ "$spinType" == "4" ]; then
  echo "Installing Fedora MATE-Compiz"
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-MATE_Compiz-Live-x86_64-31-1.9.iso
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
elif [ "$spinType" == "5" ]; then
  echo "Installing Fedora Cinnamon"
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-Cinnamon-Live-x86_64-31-1.9.iso
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
elif [ "$spinType" == "6" ]; then
  echo "Installing Fedora LXDE"
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-LXDE-Live-x86_64-31-1.9.iso
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
elif [ "$spinType" == "7" ]; then
  echo "Installing Fedora SoaS"
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-SoaS-Live-x86_64-31-1.9.iso
  wget https://arm.fedoraproject.org/static/checksums/Fedora-Spins-31-1.9-armhfp-CHECKSUM
else 
  echo "Incorrect input"
  exit
fi


isoFile=(*.iso)

echo ".iso installed successfully."

#get and verify the checksums

echo ""

echo "Starting checksum check..."

echo ""

curl https://getfedora.org/static/fedora.gpg | gpg --import
gpg --verify-files *-CHECKSUM
verify=$(sha256sum -c *-CHECKSUM)

if [[ "$verify" != *": OK"* ]]; then
  echo "Incorrect checksum."
  exit
fi

echo ""

echo "Checksum Valid."

#finds attached USB devices
echo " "

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



#burns .iso file to USB
#check UEFI support
echo " "
while true
do
  echo "Does your system support UEFI? (If you select y, the script will format the USB in FAT32," 
  echo "this has the advantage of not destroying your USB) y/n"
  read typeBurn 
  if [ "$typeBurn" == "y" ]; then
    echo "Burning to drive (FAT32) ..."
    break
  fi
  if [ "$typeBurn" == "n" ]; then
    echo "Burning to drive (Normal) ..."
    sudo umount $usbDir
    sudo dd bs=8M if=$isoFile of=$usbDir oflag=direct  status=progress
    echo "Success!"
    exit
  fi
  echo "Incorrect option"
done
#FAT32 burn

sudo umount $usbDir

usbDir=$(udisksctl mount -b $usbDir)
usbDir=$(echo $usbDir | cut -d'.' -f 1)
usbDir=${usbDir:21}

echo "This may take a while. Do not shut down the program until the success message appears."

cp "$isoFile" "$usbDir"

echo "Success!"
