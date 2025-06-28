#!/usr/bin/env bash
#
# python.sh - Python related functions
#

install_python_packages() {
    log_message "INFO" "Installing Python packages..."
    log_message "INFO" "Creating virtual environment..."
    benv venvutil python=3.12
    log_message "INFO" "Installing Python packages..."
    pip install -r "$__SETUP_BASE/requirements.txt" 2>&1 | tee -a "$INSTALL_CONFIG/install.log" >&2
    log_message "INFO" "Installing the NLTK models locally in VENV: ${CONDA_DEFAULT_ENV}"
    python <<_EOT_
import nltk
nltk.download('punkt')
nltk.download('stopwords')
_EOT_
    log_message "INFO" "NLTK data installed successfully."
    return 0
}
