#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export EXP_MODEL_DIR=$DIR/models
export EXP_VALID_SCRIPT=$DIR/validate.sh
export EXP_RUN_SCRIPT=$DIR/run.sh
export EXP_ENV=$DIR/env.sh

export EXP_SUBWORD_NMT_DIR=/home/TILDE.LV/marcis.pinnis/tools/prod-subword-nmt
export EXP_MOSES_SCRIPTS_DIR=/home/TILDE.LV/toms.bergmanis/software/mosesdecoder/scripts
export EXP_MARIAN=/home/TILDE.LV/arturs.stafanovics/marian/build

export EXP_DICT_SRC=$DIR/shared-vocab.yml
export EXP_DICT_TRG=$DIR/shared-vocab.yml

export EXP_HOME_DIR=$DIR