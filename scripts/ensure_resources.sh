#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TEST_RES="$SCRIPT_DIR/../resources"
S3_BUCKET="spec.ccfc.min"
TARGET="$(uname -m)"
FC_VERSION="v1.1.2"

ensure_firecracker() {
    file_path="$TEST_RES/firecracker"

    # Get the specified firecracker version.
    TMP_FOLDER="/tmp/tmprelease"
    TMP_ARCHIVE="/tmp/release.tgz"

    wget -q "https://github.com/firecracker-microvm/firecracker/releases/download/$FC_VERSION/firecracker-$FC_VERSION-$TARGET.tgz" -O "$TMP_ARCHIVE"

    mkdir -p "$TMP_FOLDER"
    tar -zxf "$TMP_ARCHIVE" -C "$TMP_FOLDER"

    # Get the firecracker binary
    cp "$(find "$TMP_FOLDER" -name "firecracker*$TARGET*")" "$file_path"
    chmod +x "$file_path"

    echo "Saved firecracker at $file_path"

    # Clean up
    rm -rf "$TMP_FOLDER"
    rm "$TMP_ARCHIVE"

}

ensure_kernel() {
    file_path="$TEST_RES/vmlinux"
    kv="4.14"
    wget -q "https://s3.amazonaws.com/$S3_BUCKET/ci-artifacts/kernels/$TARGET/vmlinux-$kv.bin" -O "$file_path"
    echo "Saved kernel at $file_path..."
}

ensure_rootfs() {
    file_path="$TEST_RES/rootfs.ext4"
    key_path="$TEST_RES/rootfs.id_rsa"
    wget -q "https://s3.amazonaws.com/$S3_BUCKET/img/alpine_demo/fsfiles/xenial.rootfs.ext4" -O "$file_path"
    wget -q "https://s3.amazonaws.com/$S3_BUCKET/img/alpine_demo/fsfiles/xenial.rootfs.id_rsa" -O "$key_path"
    chmod 400 "$key_path"
    echo "Saved rootfs and ssh key at $file_path and $key_path..."
}

mkdir -p "$TEST_RES"

# Obtain Firecracker.
ensure_firecracker
ensure_kernel
ensure_rootfs
