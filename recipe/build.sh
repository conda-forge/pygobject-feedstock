#!/usr/bin/env bash

set -ex

# get meson to find pkg-config when cross compiling
export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

meson_config_args=(
  --wrap-mode=nofallback
  --backend=ninja
  -Dtests=false
  -Dpython="$PYTHON"
)

meson setup forgebuild ${MESON_ARGS} "${meson_config_args[@]}"
ninja -v -C forgebuild -j ${CPU_COUNT}
ninja -C forgebuild install -j ${CPU_COUNT}
