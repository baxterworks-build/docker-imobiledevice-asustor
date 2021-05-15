#FROM debian:stable-slim
FROM voltagex/x86_64-asustor-linux-gnu:3.5
ENV CC=$TRIPLET-gcc
ENV CXX=$TRIPLET-c++
ENV AR=$TRIPLET-ar

ENV PKG_CONFIG_PATH="/opt/lib/pkgconfig/:/usr/lib/pkgconfig/"
ENV PATH="/opt/bin:$PATH"

ENV AUTOGEN_COMMAND="./autogen.sh --prefix=/opt/ --without-cython"
ENV CONFIGURE_COMMAND="./configure --prefix=/opt --without-cython"

RUN apt update && apt -y --no-install-recommends install curl ca-certificates git autoconf automake pkg-config make bzip2 gcc-8- cpp-8- file patchelf #libtool ssl

RUN mkdir /src
WORKDIR /src

RUN curl -L https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz | tar -zxf -
WORKDIR /src/libtool-2.4.6
RUN ./configure --prefix=/opt && make -j`nproc` && make install
WORKDIR /src

RUN curl -L https://www.openssl.org/source/openssl-1.1.1k.tar.gz | tar -zxf -
WORKDIR /src/openssl-1.1.1k
RUN ./config --prefix=/opt/
RUN make -j `nproc` && make install_sw
WORKDIR /src

#1.0.24 requires C11 which ASUSTOR doesn't provide in their toolchain.
RUN curl -L https://github.com/libusb/libusb/releases/download/v1.0.23/libusb-1.0.23.tar.bz2 | tar -jxf -
WORKDIR /src/libusb-1.0.23
RUN ./configure --prefix=/opt --disable-udev && make -j`nproc` && make install

WORKDIR /src/
RUN for i in libplist libusbmuxd libimobiledevice usbmuxd; \ 
	do \ 
		git clone --depth=1 https://github.com/libimobiledevice/$i; \
		cd /src/$i && \ 
		$AUTOGEN_COMMAND && $CONFIGURE_COMMAND && \ 
		make -j`nproc` && make install && cd /src; \ 
	done

RUN mv /opt/sbin/usbmuxd /opt/bin/
RUN for i in `ls /opt/bin/`; do patchelf --set-interpreter /opt/lib/ld-linux-x86-64.so.2 /opt/bin/$i; done
RUN tar --exclude=/opt/compiler -cf /src/imobiledevice.tar /opt

