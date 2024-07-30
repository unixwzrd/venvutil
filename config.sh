#!/bin/bash

# Default location fofr the install base and the build directory where libraries and
# other code wil be staged, configured, built and installed from.
#
# The default location is the current directory.
BUILD_BASE=${PWD}
echo "==============================================> BUILD_BASE SET TO: ${BUILD_BASE}"
BUILD_DIR=${PWD}/build
echo "==============================================> BUILD_DIR SET TO: ${BUILD_DIR}"

# ACCELERATE_CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework =Wl,Accelerate -DNO_ATLAS_INFO=3 -DHAVE_CBLAS"

# Application code prefix for the VENV builds. Two or three letters to allow
# grouping of the VENV's when getting an environment listing.
APPP_CODE="bld"

__URL_LLAMA_CPP=https://github.com/ggerganov/llama.cpp.git
__URL_LLAMA_CPP_PYTHON=https://github.com/abetlen/llama-cpp-python.git

# PACKAGE_INSTALL branch and layer ordering for each package install/re-install/recompile
#
# Package swquence by package name. There are two columns in this.
#
# INSTYP    - Install type, what sort of installation this is going to be, Once, New, Re-build/install
#               O   - Install once for whole system, like a library or binary executable to install
#                     in /usr/local
#               N   - New install which has not been installed in any or th eprior VENVs.
#               R   - Re-install/compile/build for each VENV it's already been installed in.
#               I   - Install in all VENVs (Same as R type)
#             
# PAACKAGE  - The package in sequence corresponding to the PACKAGE in PACKAGE_CONFIG.
#
PACKAGE_INSTALL=(
#    PACKAGE          | INSTYPE
    "numpy            | I "
    "pytorch          | I "
    "webui            | O "
#   "oobapkgs"        | O "
#   "oobaxtn"         | O "
    "numpy            | R "
    "llama-cpp-python | I "
)
PI_PACKAGE=0
PI_INSTYPE=1

# PACKAGE_CONFIG specifications for each Python or Conda package installation.
# TODO - The layering/Branching is not implemented yet, right now things are layered
#        from a starting base with the required version of Python.
# TODO - Add function calling ability and adding functions to this config.sh file.
# TODO - "Sandboxing" of libraries in their own "PREFIX" location like /usr/local
#        but rather a unique location so runtime and static linkers will use that
#        location for lobraries instead of th edefault.
#
# CONFIG      - unique build identifier
# DESCRIPRION - Long Description of the configuration
# PACKAGE     - The pyPi or Conda package identifier
# ALT_NAME    - For packages like PyTorch wihich have a difefrent or alternate name depending
#               on th epackage source.
# PRE_FLAGS   - Pre Conda/Pip flags passed
# METHOD      - Method of install or package manager to use ( pip | conda | git | func )
# POST_FLAGS  - Installer invication flags
#
PACKAGE_CONFIG=(
#    CONFIG     | DESCRIPTION                                                      | PACKAGE   | ALT_NAME | PRE_FLAGS                                         | METHOD|  POST_FLAGS
#   "base       | Standard Pip install                                              | numpy     | |                                                           | pip   | "
#   "conda      | Standard Conda package install                                    | numpy     | |                                                           | conda | -y"
#   "recomp     | Standard Pip recompile - non-binary install                       | numpy     | |                                                           | pip   | --force-reinstall --no-cache --no-binary :all: --compile"
#   "accelerate | Pip install using Accelerate Framework where possible             | numpy     | | NPY_BLAS_ORDER='accelerate' NPY_LAPACK_ORDER='accelerate' | pip   | --force-reinstall --no-cache --no-binary :all: --compile"
#   "oblas      | Pip Install recompile using OpenBLAS                              | numpy     | | NPY_BLAS_ORDER='openblas' NPY_LAPACK_ORDER='openblas'     | pip   | --force-reinstall --no-cache --no-binary :all: --compile"
#   "blis       | Pip Install recompile using BLIS                                  | numpy     | | NPY_BLAS_ORDER='blis'                                     | pip   | --force-reinstall --no-cache --no-binary :all: --compile"
#   "blisblas   | Pip Install recompile using BLIS for OpenBLAS and BLAS for LAPACK | numpy     | | NPY_BLAS_ORDER='blis' NPY_LAPACK_ORDER='openblas'         | pip   | --force-reinstall --no-cache --no-binary :all: --compile"
#   "pip        | Stangard pip install for Torch                                    | pytorch   | torch |                                                     | pip   | torchvision"
#   "base       | Base Conda install for Torch                                      | pytorch   | |                                                           | conda | torchvision -c pytorch --force-install -y"
#   "llama      | Stangard pip install for lama-cpp-python                          | llama-cpp-python | | CMAKE_ARGS='-DLLAMA_METAL=on' FORCE_CMAKE=1        | pip   | "
#   "oobabase   | Oobabooga install                                                 | webui     | |                                                           | git   | clone https://github.com/oobabooga/text-generation-webui.git webui"
#   "oobapkg    | Install oobagooba's packages using a function call                | oobapkg   | |                                                           | func  | "
#   "oobaext    | oobaboogs extensions                                              | oobaext   | |                                                           | func  | "
)
PC_CONFIG=0
PC_DESC=1
PC_PACKAGE=2
PC_ALT_NAME=3
PC_PRE_FLAGS=4
PC_METHOD=5
PC_POST_FLAGS=6


oobapkg() {
    echo 
    cd ${BUILD_DIR}/webui
    pip install -r requirements.txt
}


EXTENSIONS=(
#   "api"
#   "character_bias"
#   "elevenlabs_tts"
#   "example"
#   "gallery"
#   "google_translate"
#   "multimodal"
#   "ngrok"
#   "openai"
#   "perplexity_colors"
#   "sd_api_pictures"
#   "send_pictures"
#   "silero_tts"
#   "superbooga"
#   "whisper_stt"
)

oobaxtns() {
    echo "INSTALLING OOBABOOGA EXTENSION PACKAGES"
    cd ${BUILD_DIR}/webui
}
