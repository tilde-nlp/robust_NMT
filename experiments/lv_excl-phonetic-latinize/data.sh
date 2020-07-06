#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export DATA_DIR=/home/TILDE.LV/arturs.stafanovics/robust_NMT/data/lv/excl-phonetic-latinize

export EXP_SRC=lv
export EXP_TRG=en

export DEVEL_PREFIX=newsdev2017.tc
export CORPUS_PREFIX=corpus.tc

export EXP_TRAIN_SRC=$DATA_DIR/$CORPUS_PREFIX.bpe.$EXP_SRC
export EXP_TRAIN_TRG=$DATA_DIR/$CORPUS_PREFIX.bpe.$EXP_TRG

export EXP_VALID_SRC=$DATA_DIR/$DEVEL_PREFIX.bpe.$EXP_SRC
export EXP_VALID_TRG=$DATA_DIR/$DEVEL_PREFIX.bpe.$EXP_TRG

export EXP_PROCESS_VALID_SRC=$DATA_DIR/$DEVEL_PREFIX.$EXP_SRC
export EXP_PROCESS_VALID_TRG=$DATA_DIR/$DEVEL_PREFIX.$EXP_TRG

