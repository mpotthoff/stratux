#!/bin/bash

#apt-get install -y dh-make

stratuxVersion=`git describe --tags --abbrev=0`
stratuxBuild=`git log -n 1 --pretty=%H`

echo
echo
echo "Packaging ${stratuxVersion} (${stratuxBuild})."
echo
echo

cd ..
make
rm -rf work
mkdir -p work/bin
make optinstall STRATUX_HOME=$(pwd)/work/bin/stratux
cp __lib__systemd__system__stratux.service work/bin/
cp image/config.txt work/bin/
cp image/rtl-sdr-blacklist.conf work/bin/
cp image/bashrc.txt work/bin/
cp image/modules.txt work/bin/
cp image/stxAliases.txt work/bin/
cp image/10-stratux.rules work/bin/
cp image/99-uavionix.rules work/bin/
cp image/motd work/bin/
cp image/stratux-wifi.sh work/bin/
cp image/rc.local work/bin/
cp image/logrotate.conf work/bin/
cp image/logrotate_d_stratux work/bin/
cp image/rsyslog_d_stratux work/bin/

if [ "$(arch)" == "aarch64" ]; then
	echo -e "\narm_64bit=1" >> work/bin/config.txt
fi

cd work/
echo "Compressing files..."
cd bin
tar cjvf ../files.tar.bz2 .
cd ..

cat ../selfupdate/update_header.sh >update.sh

echo "stratuxVersion=${stratuxVersion}" >>update.sh
echo "stratuxBuild=${stratuxBuild}" >>update.sh

echo "packing files.tar.bz2"
#echo "base64 -d | tar xjvf - <<__EOF__" >> update.sh # ??
echo "base64 -d > files.tar.bz2 <<__EOF__" >> update.sh
base64 files.tar.bz2 >> update.sh
echo "__EOF__" >> update.sh
echo "tar xjvf files.tar.bz2" >> update.sh
echo "done"

cat ../selfupdate/update_footer.sh >>update.sh

chmod +x update.sh

OUTF="update-stratux-${stratuxVersion}-${stratuxBuild:0:10}.sh"
mv update.sh $OUTF


echo
echo
echo "$OUTF ready."
echo
echo
