This builds libimobiledevice and associated programs from git master, targeting the ASUSTOR AS6604T NAS.

The readelf line is so that it uses Entware's ancient libc instead of ASUSTOR's prehistoric one.

Yeah, I could have patched Entware to use newer sources, but the OpenWRT build system makes me stabby on the best of days.
