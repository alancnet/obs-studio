#!/bin/bash
# Configure Alan's default OBS: 32.2.2 + the Wayland projector workaround
# (branch wayland-projector-fix), with the same options as Arch's
# obs-studio 32.2.2-1 package (Arch packaging repo, tag 32.2.2-1), installed to
# ~/work/obs-projector/default/install. Not portable: uses ~/.config/obs-studio.
set -e
# Build deps kept local instead of system packages: swig (pip venv),
# header-only asio 1.30.2 and websocketpp 0.8.2 (deps/prefix).
DEPS=$HOME/work/obs-projector/default/deps
export PATH=$HOME/work/hdr-10bit/venv/bin:$DEPS/venv/bin:$PATH
export PKG_CONFIG_PATH=/usr/lib/mbedtls3/pkgconfig
S=$HOME/work/obs-projector/src
P=$HOME/work/obs-projector/src/culvert/patches

# Same obs-browser prep as the PKGBUILD (applied once, uncommitted in the
# submodule): C++20 and CEF 6613+ patches, rpath to the system CEF.
cd $S/plugins/obs-browser
if git apply --check -p1 $P/obs-browser-Update-to-C-20.patch 2>/dev/null; then
  git apply -p1 $P/obs-browser-Update-to-C-20.patch
  git apply -p1 $P/obs-browser-enable-support-for-CEF-6613+.patch
  sed -e 's|INSTALL_RPATH ".*"|INSTALL_RPATH "/usr/lib/cef/"|' -i cmake/os-linux.cmake
fi

cef_api=$(grep -oP 'CEF_API_VERSION_LAST CEF_API_VERSION_\K[0-9]+' /usr/include/cef/include/cef_api_versions.h)
cd $S
# CMAKE_MODULE_PATH first so the system FindCEF (from the cef package) wins
# over OBS's bundled one, instead of deleting it like the PKGBUILD does.
cmake -S . -B build-default -G Ninja -Wno-dev \
  -DCMAKE_MODULE_PATH=/usr/share/cmake/Modules \
  -DCMAKE_PREFIX_PATH=$DEPS/prefix \
  -DECM_DIR=$HOME/work/obs-hdr/ecm/usr/share/ECM/cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX=$HOME/work/obs-projector/default/install \
  -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF \
  -DENABLE_BROWSER=ON -DCEF_API_VERSION=$cef_api \
  -DENABLE_VST=ON -DENABLE_VLC=OFF -DENABLE_NEW_MPEGTS_OUTPUT=OFF \
  -DENABLE_AJA=OFF -DENABLE_JACK=ON -DENABLE_LIBFDK=ON -DENABLE_WEBRTC=ON \
  -DOBS_VERSION_OVERRIDE=32.2.2 -DCALM_DEPRECATION=ON -DENABLE_WEBSOCKET=ON "$@"
