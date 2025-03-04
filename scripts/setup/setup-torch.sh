#!/bin/bash
# Script to install PyTorch 2.5.0
# Handles both x86_64 and ARM (Nvidia Jetson) architectures

set -euo pipefail

# Check if the correct PyTorch version is already installed
if pip show torch 2>&1 | grep -iq "Version: 2.5.0" ; then
  echo "Correct PyTorch version already installed. Done."
  exit 0
fi

# Verify sudo/root access which is required for installation
if [[ "$EUID" -ne 0 ]] ; then
  echo "ERROR: PyTorch install must be run as root, please run:"
  echo "  sudo $0"
  exit 1
fi

# Detect architecture and install appropriate PyTorch version
readonly arch=$(uname -m)
if [[ $arch == x86_64* ]]; then
    echo "Detected x64 architecture. Installing regular PyTorch."
    pip install torch==2.5.0
elif  [[ $arch == aarch64* ]]; then
    echo "Detected ARM architecture. Installing PyTorch for Nvidia Jetsons."
    # Create temporary working directory for installation files
    readonly TMP_WORKDIR=/tmp/pytorch
    rm -rf ${TMP_WORKDIR}
    mkdir ${TMP_WORKDIR}
    pushd ${TMP_WORKDIR} > /dev/null
    
    # Install OpenBLAS dependency
    apt-get update
    apt-get install -yq --no-install-recommends \
            curl \
            libopenblas-dev
            
    # Install cuSPARSELt library required by Nvidia's torch from version nv24.06 onwards
    CUSPARSELT_NAME="libcusparse_lt-linux-sbsa-0.5.2.1-archive"
    curl --retry 3 -OLs https://developer.download.nvidia.com/compute/cusparselt/redist/libcusparse_lt/linux-sbsa/${CUSPARSELT_NAME}.tar.xz
    echo 33b9a9cec5329dddd3db93abc31c35e1 ${CUSPARSELT_NAME}.tar.xz | md5sum --check --quiet --strict -
    tar xf ${CUSPARSELT_NAME}.tar.xz
    mkdir -p /usr/local/cuda/include/
    mkdir -p /usr/local/cuda/lib64/
    cp -a ${CUSPARSELT_NAME}/include/* /usr/local/cuda/include/
    cp -a ${CUSPARSELT_NAME}/lib/* /usr/local/cuda/lib64/
    ldconfig
    
    # Download and install Nvidia's Jetson-optimized PyTorch package
    TORCH_WHEEL_NAME="torch-2.5.0a0+872d972e41.nv24.08.17622132-cp310-cp310-linux_aarch64.whl"
    curl --retry 3 -OLs https://developer.download.nvidia.cn/compute/redist/jp/v61/pytorch/${TORCH_WHEEL_NAME}
    echo e216530785085ae4e1c29975094c1e42 ${TORCH_WHEEL_NAME} | md5sum --check --quiet --strict -
    pip install --no-cache ${TORCH_WHEEL_NAME}
    
    # Clean up installation files
    rm -rf ${TMP_WORKDIR}
    popd > /dev/null
else
    echo "Unsupported architecture '$arch'. Aborting installation."
    exit 1
fi

echo "PyTorch 2.5.0 installation completed successfully."
