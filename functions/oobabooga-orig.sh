#!/bin/sh

# Installation functions for oobabooga 

oobapkgs() {
    echo "${MY_NAME}: Installing all application packages."
    cd ${BUILD_DIR}/webui-macOS
    # CLone the current VENV and make the clone active.
    ccln oobapkgs
    pip install -r requirements.txt
}

EXTENSIONS=(
#   "api"
#   "character_bias"
    "elevenlabs_tts"
#   "example"
    "gallery"
#   "google_translate"
#   "multimodal"
#   "ngrok"
#   "openai"
#   "perplexity_colors"
#   "sd_api_pictures"
#   "send_pictures"
   "silero_tts"
#   "superbooga"
#   "whisper_stt"
)

oobaxtns() {
    echo "${MY_NAME}: Installing oobabooga extension packages"
    cd ${BUILD_DIR}/webui-macOS
    pip install -r requirements.txt
    for extn in ${EXTENSIONS[@]}; do
        echo "${MY_NAME}: INstalling package extension - ${extn}"
        cd ${extn}
        pip install -r requirements.txt
        cd ${BUILD_DIR}/webui-macOS
    done
}