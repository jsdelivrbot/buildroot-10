################################################################################
#
# efl
#
################################################################################

EFL_VERSION = 1.16.1
EFL_SOURCE = efl-$(EFL_VERSION).tar.xz
EFL_SITE = http://download.enlightenment.org/rel/libs/efl
EFL_LICENSE = BSD-2c, LGPLv2.1+, GPLv2+
EFL_LICENSE_FILES = \
	COMPLIANCE \
	COPYING \
	licenses/COPYING.BSD \
	licenses/COPYING.FTL \
	licenses/COPYING.GPL \
	licenses/COPYING.LGPL \
	licenses/COPYING.SMALL

EFL_INSTALL_STAGING = YES

EFL_DEPENDENCIES = host-pkgconf host-efl host-luainterpreter dbus freetype \
	jpeg luainterpreter udev util-linux zlib

# Regenerate the autotools:
#  - to fix an issue in eldbus-codegen: https://phab.enlightenment.org/T2718
EFL_AUTORECONF = YES
EFL_GETTEXTIZE = YES

# Configure options:
# --disable-sdl: disable sdl2 support.
# --disable-systemd: disable systemd support.
EFL_CONF_OPTS = \
	--with-edje-cc=$(HOST_DIR)/usr/bin/edje_cc \
	--with-elua=$(HOST_DIR)/usr/bin/elua \
	--with-eolian-gen=$(HOST_DIR)/usr/bin/eolian_gen \
	--with-eolian-cxx=$(HOST_DIR)/usr/bin/eolian_cxx \
	--disable-sdl \
	--disable-systemd

# enable C++ bindings if the toolchain has C++11 support.
ifeq ($(BR2_PACKAGE_EFL_CPP_SUPPORT),y)
EFL_CONF_OPTS += --enable-cxx-bindings
else
EFL_CONF_OPTS += --disable-cxx-bindings
endif

# Disable untested configuration warning.
ifeq ($(BR2_PACKAGE_EFL_HAS_RECOMMENDED_CONFIG),)
EFL_CONF_OPTS += --enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-aba
endif

# We need to build Elua for the host to enable luajit support for the target.
# --disable-lua-old: build elua for the target.
# --enable-lua-old: disable Elua and remove luajit dependency.
ifeq ($(BR2_PACKAGE_LUAJIT),y)
EFL_CONF_OPTS += --disable-lua-old
else
EFL_CONF_OPTS += --enable-lua-old
endif

ifeq ($(BR2_PACKAGE_UTIL_LINUX_LIBMOUNT),y)
EFL_DEPENDENCIES += util-linux
EFL_CONF_OPTS += --enable-libmount
else
EFL_CONF_OPTS += --disable-libmount
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
EFL_CONF_OPTS += --enable-systemd
EFL_DEPENDENCIES += systemd
else
EFL_CONF_OPTS += --disable-systemd
endif

ifeq ($(BR2_PACKAGE_FONTCONFIG),y)
EFL_CONF_OPTS += --enable-fontconfig
EFL_DEPENDENCIES += fontconfig
else
EFL_CONF_OPTS += --disable-fontconfig
endif

ifeq ($(BR2_PACKAGE_LIBFRIBIDI),y)
EFL_CONF_OPTS += --enable-fribidi
EFL_DEPENDENCIES += libfribidi
else
EFL_CONF_OPTS += --disable-fribidi
endif

ifeq ($(BR2_PACKAGE_GSTREAMER1)$(BR2_PACKAGE_GST1_PLUGINS_BASE),yy)
EFL_CONF_OPTS += --enable-gstreamer1
EFL_DEPENDENCIES += gstreamer1 gst1-plugins-base
else
EFL_CONF_OPTS += --disable-gstreamer1
endif

ifeq ($(BR2_PACKAGE_BULLET),y)
EFL_CONF_OPTS += --enable-physics
EFL_DEPENDENCIES += bullet
else
EFL_CONF_OPTS += --disable-physics
endif

ifeq ($(BR2_PACKAGE_LIBSNDFILE),y)
EFL_CONF_OPTS += --enable-audio
EFL_DEPENDENCIES += libsndfile
else
EFL_CONF_OPTS += --disable-audio
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
EFL_CONF_OPTS += --enable-pulseaudio
EFL_DEPENDENCIES += pulseaudio
else
EFL_CONF_OPTS += --disable-pulseaudio
endif

ifeq ($(BR2_PACKAGE_HARFBUZZ),y)
EFL_DEPENDENCIES += harfbuzz
EFL_CONF_OPTS += --enable-harfbuzz
else
EFL_CONF_OPTS += --disable-harfbuzz
endif

ifeq ($(BR2_PACKAGE_TSLIB),y)
EFL_DEPENDENCIES += tslib
EFL_CONF_OPTS += --enable-tslib
else
EFL_CONF_OPTS += --disable-tslib
endif

ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
EFL_DEPENDENCIES += libglib2
EFL_CONF_OPTS += --with-glib=yes
else
EFL_CONF_OPTS += --with-glib=no
endif

# Prefer openssl (the default) over gnutls.
ifeq ($(BR2_PACKAGE_OPENSSL),y)
EFL_DEPENDENCIES += openssl
EFL_CONF_OPTS += --with-crypto=openssl
else ifeq ($(BR2_PACKAGE_GNUTLS)$(BR2_PACKAGE_LIBGCRYPT),yy)
EFL_DEPENDENCIES += gnutls libgcrypt
EFL_CONF_OPTS += --with-crypto=gnutls \
	--with-libgcrypt-prefix=$(STAGING_DIR)/usr
else
EFL_CONF_OPTS += --with-crypto=none
endif # BR2_PACKAGE_OPENSSL

ifeq ($(BR2_PACKAGE_WAYLAND),y)
EFL_DEPENDENCIES += wayland libxkbcommon
EFL_CONF_OPTS += --enable-wayland
else
EFL_CONF_OPTS += --disable-wayland
endif

ifeq ($(BR2_PACKAGE_EFL_FB),y)
EFL_CONF_OPTS += --enable-fb
else
EFL_CONF_OPTS += --disable-fb
endif

# --enable-xinput22 is recommended
ifeq ($(BR2_PACKAGE_EFL_X_XLIB),y)
EFL_CONF_OPTS += \
	--with-x11=xlib \
	--with-x=$(STAGING_DIR) \
	--x-includes=$(STAGING_DIR)/usr/include \
	--x-libraries=$(STAGING_DIR)/usr/lib \
	--enable-xinput22

EFL_DEPENDENCIES += \
	xlib_libX11 \
	xlib_libXcomposite \
	xlib_libXcursor \
	xlib_libXdamage \
	xlib_libXext \
	xlib_libXi \
	xlib_libXinerama \
	xlib_libXrandr \
	xlib_libXrender \
	xlib_libXScrnSaver \
	xlib_libXtst
else
EFL_CONF_OPTS += --with-x11=none
endif

ifeq ($(BR2_PACKAGE_EFL_OPENGL),y)
EFL_CONF_OPTS += --with-opengl=full
EFL_DEPENDENCIES += libgl
endif

# OpenGL ES requires EGL
ifeq ($(BR2_PACKAGE_EFL_OPENGLES),y)
EFL_CONF_OPTS += --with-opengl=es --enable-egl
EFL_DEPENDENCIES += libgles
endif

ifeq ($(BR2_PACKAGE_EFL_OPENGL_NONE),y)
EFL_CONF_OPTS += --with-opengl=none
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXPRESENT),y)
EFL_CONF_OPTS += --enable-xpresent
EFL_DEPENDENCIES += xlib_libXpresent
endif

# Loaders that need external dependencies needs to be --enable-XXX=yes
# otherwise the default is '=static'.
# All other loaders are statically built-in
ifeq ($(BR2_PACKAGE_EFL_PNG),y)
EFL_CONF_OPTS += --enable-image-loader-png=yes
EFL_DEPENDENCIES += libpng
else
EFL_CONF_OPTS += --disable-image-loader-png
endif

ifeq ($(BR2_PACKAGE_EFL_JPEG),y)
EFL_CONF_OPTS += --enable-image-loader-jpeg=yes
# efl already depends on jpeg.
else
EFL_CONF_OPTS += --disable-image-loader-jpeg
endif

ifeq ($(BR2_PACKAGE_EFL_GIF),y)
EFL_CONF_OPTS += --enable-image-loader-gif=yes
EFL_DEPENDENCIES += giflib
else
EFL_CONF_OPTS += --disable-image-loader-gif
endif

ifeq ($(BR2_PACKAGE_EFL_TIFF),y)
EFL_CONF_OPTS += --enable-image-loader-tiff=yes
EFL_DEPENDENCIES += tiff
else
EFL_CONF_OPTS += --disable-image-loader-tiff
endif

ifeq ($(BR2_PACKAGE_EFL_JP2K),y)
EFL_CONF_OPTS += --enable-image-loader-jp2k=yes
EFL_DEPENDENCIES += openjpeg
else
EFL_CONF_OPTS += --disable-image-loader-jp2k
endif

ifeq ($(BR2_PACKAGE_EFL_WEBP),y)
EFL_CONF_OPTS += --enable-image-loader-webp=yes
EFL_DEPENDENCIES += webp
else
EFL_CONF_OPTS += --disable-image-loader-webp
endif

$(eval $(autotools-package))

################################################################################
#
# host-efl
#
################################################################################

# We want to build only some host tools used later in the build.
# Actually we want: edje_cc, eet, embryo_cc and eolian_cxx.

# Host dependencies:
# * host-dbus: for Eldbus
# * host-freetype: for libevas
# * host-libglib2: for libecore
# * host-libjpeg, host-libpng: for libevas image loader
# * host-luainterpreter: host-luajit for Elua tool for the host
#   or host-lua for lua-old option
HOST_EFL_DEPENDENCIES = \
	host-pkgconf \
	host-dbus \
	host-freetype \
	host-libglib2 \
	host-libjpeg \
	host-libpng \
	host-luainterpreter \
	host-zlib

# If luajit is enabled for the target, we need to build Elua for the host.
# --disable-lua-old: build elua for the host.
# --enable-lua-old: disable Elua and remove luajit dependency.
ifeq ($(BR2_PACKAGE_LUAJIT),y)
HOST_EFL_CONF_OPTS += --disable-lua-old
else
HOST_EFL_CONF_OPTS += --enable-lua-old
endif

# Enable C++11 bindings to provide eolian_cxx
ifeq ($(BR2_PACKAGE_EFL_CPP_SUPPORT),y)
HOST_EFL_CONF_OPTS += --enable-cxx-bindings
else
HOST_EFL_CONF_OPTS += --disable-cxx-bindings
endif

# Configure options:
# --disable-audio, --disable-multisense remove libsndfile dependency.
# --disable-fontconfig: remove dependency on fontconfig.
# --disable-fribidi: remove dependency on libfribidi.
# --disable-gstreamer1: remove dependency on gtreamer 1.0.
# --disable-libeeze: remove libudev dependency.
# --disable-libmount: remove dependency on host-util-linux libmount.
# --disable-physics: remove Bullet dependency.
# --enable-image-loader-gif=no: disable Gif dependency.
# --enable-image-loader-tiff=no: disable Tiff dependency.
# --with-crypto=none: remove dependencies on openssl or gnutls.
# --with-x11=none: remove dependency on X.org.
#   Yes I really know what I am doing.
HOST_EFL_CONF_OPTS += \
	--disable-audio \
	--disable-fontconfig \
	--disable-fribidi \
	--disable-gstreamer1 \
	--disable-libeeze \
	--disable-libmount \
	--disable-multisense \
	--disable-physics \
	--enable-image-loader-gif=no \
	--enable-image-loader-jpeg=yes \
	--enable-image-loader-png=yes \
	--enable-image-loader-tiff=no \
	--with-crypto=none \
	--with-glib=yes \
	--with-opengl=none \
	--with-x11=none \
	--enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-aba

$(eval $(host-autotools-package))
