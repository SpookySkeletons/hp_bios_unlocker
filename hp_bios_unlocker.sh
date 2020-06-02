#Clean.bin is a hex dump of the empty password character set of HP's VSS.
#Shell script requires binwalk && dd to operate.

BIOS_MODEL="\x48\x00\x50\x00\x5F\x00\x4D\x00\x4F\x00\x44\x00\x45\x00\x4C\x00\x00\x00"
BIOS_USER="\x48\x00\x50\x00\x5F\x00\x42\x00\x69\x00\x6F\x00\x73\x00\x55\x00\x73\x00\x65\x00\x72\x00"
ONE="\x30\x00\x30\x00\x00\x00"
TWO="\x30\x00\x31\x00\x00\x00"
THREE="\x30\x00\x32\x00\x00\x00"

patchlocation00=$(binwalk -R $BIOS_USER$ONE "$1" | grep -oE '^\s*[0-9]+' | tail -n1)
patchlocation01=$(binwalk -R $BIOS_USER$TWO "$1" | grep -oE '^\s*[0-9]+' | tail -n1)
patchlocation02=$(binwalk -R $BIOS_USER$THREE "$1" | grep -oE '^\s*[0-9]+' | tail -n1)

offset_fail() {
    echo "!!!Failed to find flash offset bailing out!!!"
    exit 1
}

echo "Verifying file offsets..."

if [ ! -z $patchlocation00 ] && [ ! -z $patchlocation01 ] && [ ! -z $patchlocation02 ]; then
  
    echo "Patching BIOS password data..."

    echo $((patchlocation00+28))
    echo $((patchlocation01+28))
    echo $((patchlocation02+28))

    dd bs=1 conv=notrunc seek=$((patchlocation00+28)) if=clean.bin of="$1"
    dd bs=1 conv=notrunc seek=$((patchlocation01+28)) if=clean.bin of="$1"
    dd bs=1 conv=notrunc seek=$((patchlocation02+28)) if=clean.bin of="$1"
    echo "Done."
else
   offset_fail
fi

echo "Finished patching, please reflash ROM"
