##This script will install dependencies to run Handbrake in Clear Linux
#!/bin/bash

#Install needed bundles
swupd bundle-add dev-utils dev-utils-dev devpkg-fribidi devpkg-jansson devpkg-libass devpkg-libogg devpkg-libsamplerate devpkg-libtheora devpkg-libvorbis devpkg-libvpx devpkg-opus devpkg-speex

#Check if bundle install was successful
exitcode=$(echo $?)
if [ $exitcode -eq 0 ]
	then
		echo "Bundle installation successful"
fi

#Untar, compile and install lame 3.100
tar -xf lame-3.100.tar.gz
cd lame-3.100
./configure --enable-shared --enable-static --enable-nasm
make -j$(nproc)
sudo make install-strip
cd ..

#Untar, compile and install x264
mkdir x264-snapshot-stable
tar -xf last_stable_x264.tar.bz2 --directory x264-snapshot-stable --strip-components=1
cd x264-snapshot-stable
./configure --enable-shared --enable-static --enable-lto --enable-pic --enable-strip
make -j$(nproc)
sudo make install
cd ..

#Set envoronment variables
export CFLAGS="${CFLAGS:-} -I/usr/local/include"
export LDFLAGS="${LDFLAGS:-} -L/usr/local/lib"
echo 'export CFLAGS="${CFLAGS:-} -I/usr/local/include"' >> "${HOME}/.bashrc"
echo 'export LDFLAGS="${LDFLAGS:-} -L/usr/local/lib"' >> "${HOME}/.bashrc"
if ! grep '\/usr\/local\/lib' /etc/ld.so.conf >/dev/null 2>&1; then
    echo '/usr/local/lib' | sudo tee --append /etc/ld.so.conf
    sudo ldconfig
fi

echo "Done"
