#!/usr/bin/env bash

set -ex

# get meson to find pkg-config when cross compiling
export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

# Ensure pkg-config can find host dependencies
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:$PKG_CONFIG_PATH"

# Additional paths that might contain gio-2.0.pc
export PKG_CONFIG_PATH="$PREFIX/lib64/pkgconfig:$PKG_CONFIG_PATH"

# Debug: Check if gio-2.0 can be found
echo "Checking for gio-2.0 pkg-config file..."
echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
$PKG_CONFIG --exists gio-2.0 && echo "gio-2.0 found" || echo "gio-2.0 NOT found"
$PKG_CONFIG --modversion gio-2.0 2>/dev/null || echo "Could not get gio-2.0 version"

# List available .pc files to help debug
echo "Available .pc files in pkg-config paths:"
find $PREFIX -name "*.pc" -path "*/pkgconfig/*" | grep -E "(gio|glib)" | head -10

meson_config_args=(
  --wrap-mode=nofallback
  --backend=ninja
  -Dtests=false
  -Dpython="$PYTHON"
)

meson setup forgebuild ${MESON_ARGS} "${meson_config_args[@]}"
ninja -v -C forgebuild -j ${CPU_COUNT}
ninja -C forgebuild install -j ${CPU_COUNT}
