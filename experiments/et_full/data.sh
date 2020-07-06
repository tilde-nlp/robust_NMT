#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export DATA_DIR=/home/TILDE.LV/arturs.stafanovics/robust_NMT/data/et/full

export EXP_SRC=et
export EXP_TRG=en

export DEVEL_PREFIX=newsdev2018-enet.tc
export CORPUS_PREFIX=train.tc

export EXP_TRAIN_SRC=$DATA_DIR/$CORPUS_PREFIX.bpe.$EXP_SRC
export EXP_TRAIN_TRG=$DATA_DIR/$CORPUS_PREFIX.bpe.$EXP_TRG

export EXP_VALID_SRC=$DATA_DIR/$DEVEL_PREFIX.bpe.$EXP_SRC
export EXP_VALID_TRG=$DATA_DIR/$DEVEL_PREFIX.bpe.$EXP_TRG

export EXP_PROCESS_VALID_SRC=$DATA_DIR/$DEVEL_PREFIX.$EXP_SRC
export EXP_PROCESS_VALID_TRG=$DATA_DIR/$DEVEL_PREFIX.$EXP_TRG
