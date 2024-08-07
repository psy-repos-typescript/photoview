#!/bin/sh

# Script to configure environment variables for Go compiler
# to allow cross compilation

: ${TARGETPLATFORM=}
: ${TARGETOS=}
: ${TARGETARCH=}
: ${TARGETVARIANT=}

CGO_ENABLED="$(go env CGO_ENABLED)"
GOARCH="$(go env GOARCH)"
GOOS="$(go env GOOS)"
GOARM="$(go env GOARM)"
GOBIN="$(go env GOBIN)"

set -eu

if [ ! -z "$TARGETPLATFORM" ]; then
  TARGETOS="$(echo $TARGETPLATFORM | cut -d"/" -f1)"
  TARGETARCH="$(echo $TARGETPLATFORM | cut -d"/" -f2)"
  TARGETVARIANT="$(echo $TARGETPLATFORM | cut -d"/" -f3)"
fi

if [ ! -z "$TARGETOS" ]; then
  export GOOS="$TARGETOS"
fi

if [ ! -z "$TARGETARCH" ]; then
  export GOARCH="$TARGETARCH"
fi

if [ "$TARGETARCH" = "arm" ]; then
  if [ ! -z "$TARGETVARIANT" ]; then
    case "$TARGETVARIANT" in
    "v5")
      export GOARM="5"
      ;;
    "v6")
      export GOARM="6"
      ;;
    *)
      export GOARM="7"
      ;;
    esac
  else
    export GOARM="7"
  fi
fi

if [ "$CGO_ENABLED" = "1" ]; then
  case "$GOARCH" in
  "amd64")
    export COMPILER_ARCH="x86_64-linux-gnu"
    ;;
  "ppc64le")
    export COMPILER_ARCH="powerpc64le-linux-gnu"
    ;;
  "s390x")
    export COMPILER_ARCH="s390x-linux-gnu"
    ;;
  "arm64")
    export COMPILER_ARCH="aarch64-linux-gnu"
    ;;
  "arm")
    case "$GOARM" in
    "5")
      export COMPILER_ARCH="arm-linux-gnueabi"
      ;;
    *)
      export COMPILER_ARCH="arm-linux-gnueabihf"
      ;;
    esac
    ;;
  esac
fi

export CC="${COMPILER_ARCH}-gcc"
export CXX="${COMPILER_ARCH}-g++"
export PKG_CONFIG_PATH="/usr/lib/${COMPILER_ARCH}/pkgconfig/"

if [ -z "$GOBIN" ] && [ -n "$GOPATH" ] && [ -n "$GOARCH" ] && [ -n "$GOOS" ]; then
  export PATH=${GOPATH}/bin/${GOOS}_${GOARCH}:${PATH}
fi
