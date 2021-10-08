#!/bin/bash

set -e

# Location of rust project
RUST_PROJ="$PROJECT_DIR/PlayerCore"
# Location of the "Anvil" folder in the iOS project
IOS_ANVIL="$PROJECT_DIR"
# Provide access to Rust utilities
PATH="$PATH:/Users/kit/.cargo/bin"

cd "$RUST_PROJ"

# Generate C bindings
cbindgen -l C -o target/libspottie_player_core.h

configLowercase=$(echo "$CONFIGURATION" | tr '[:upper:]' '[:lower:]')

echo "Building $configLowercase configuration for target(s) $ARCHS"

targets=()
for arch in $ARCHS; do
  if [ $arch == "arm64" ]; then
    arch="aarch64"
  fi
  targets+=($arch-apple-darwin)
done

libPaths=()
for target in "${targets[@]}"; do
  cargo build $(if [ $CONFIGURATION == "Release" ]; then echo "--release"; fi) --target $target
  
  libPaths+=("target/$target/$configLowercase/libspottie_player_core.a")
done

# Create universal library
lipo -create ${libPaths[@]} -output target/libspottie_player_core.a

# Copy resources to the iOS folder, overwriting old ones
cp target/libspottie_player_core.h target/libspottie_player_core.a "$IOS_ANVIL/Spottie/PlayerCore"
