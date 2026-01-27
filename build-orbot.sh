#!/bin/sh

rm -f ../OrbotLib.aar
rm -f ../OrbotLib-sources.jar

# should match Orbot's...
export MIN_ANDROID_SDK=24

NDK_MIN_VERSION=29

NDK_SOURCE_PROPERTIES="$ANDROID_NDK_HOME/source.properties"

if [ ! -f "$NDK_SOURCE_PROPERTIES" ]; then
  echo "--- Android NDK not found or too old."
  exit 1
fi

NDK_VERSION=$(grep "Pkg.Revision" "$NDK_SOURCE_PROPERTIES" | cut -d' ' -f3)

NDK_MAJOR_VERSION=${NDK_VERSION%%.*}

if [ "$NDK_MAJOR_VERSION" -lt "$NDK_MIN_VERSION" ]; then
  echo "--- Android NDK version $NDK_VERSION too old. Use at least version $NDK_MIN_VERSION."
  exit 1
fi

if [ -d IPtProxy ]; then
  cd IPtProxy
  git clean -fdx
  git reset --hard
  git submodule foreach --recursive git clean -fdx
  git submodule foreach --recursive git reset --hard
  cd ..
  git submodule update --init --recursive
else
  git submodule update --init --recursive
fi

if test -d "$TMPDIR"; then
    :
elif test -d "$TMP"; then
    TMPDIR=$TMP
elif test -d /var/tmp; then
    TMPDIR=/var/tmp
else
    TMPDIR=/tmp
fi

TEMPDIR="$TMPDIR/IPtProxy"
printf '\n\n--- Prepare build environment at %s...\n' "$TEMPDIR"
cd IPtProxy
CURRENT=$PWD
rm -rf "$TEMPDIR"
mkdir -p "$TEMPDIR"
cp -a . "$TEMPDIR/"

printf '\n\n--- Compile %s...\n' "$OUTPUT"
export PATH=~/Projects/Go/bin:$PATH
cd "$TEMPDIR/IPtProxy.go" || exit 1
gomobile init 
gomobile bind -o "OrbotLib.aar" -ldflags="-w -s -checklinkname=0" -target=android -androidapi="$MIN_ANDROID_SDK" -v -tags=netcgo -trimpath
cp -v OrbotLib.aar "$CURRENT/../.."
printf '\n\nDone\n'
