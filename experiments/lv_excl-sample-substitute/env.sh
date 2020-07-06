#!/bin/bash

. ./data.sh
. ./files.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# These variables must be set in the ~/.bashrc on the current machine
# Check that they are set
: "${EXP_SUBWORD_NMT_DIR:?}"
: "${EXP_MOSES_SCRIPTS_DIR:?}"
: "${EXP_HOME_DIR:?}"

# These vars must be set in files.sh or data.sh or some other place
: "${EXP_MODEL_DIR:?}"
: "${EXP_SRC}"
: "${EXP_TRG}"


export EXP_MODELS_SAVETO=$EXP_MODEL_DIR/model.npz
export EXP_VOCAB_SIZE=25000
