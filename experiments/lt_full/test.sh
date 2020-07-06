#!/bin/bash

. ./env.sh

set -eu

DEVICE_ID=${1:-0}

functions=(
  "base"
  "latinize"
  "phonetic-latinize"
  "add-diacritic"
  "delete-letters"
  "permute-letters"
  "introduce-extra-letters"
  "confuse-letters"
  "sample-substitute"
  "remove-punctuation"
  "add-comma"
  "add-punctuation"
)

TESTING_WORKSPACE=$EXP_HOME_DIR/test

mkdir -p $TESTING_WORKSPACE

all_noises=""

for key in "${functions[@]}"; do
  in_file=$DATA_DIR/../validation/$DEVEL_PREFIX.$key.bpe.$EXP_SRC
  prefix_out=$TESTING_WORKSPACE/$DEVEL_PREFIX.$key

  if [ "$key" == "base" ]; then
    in_file=$DATA_DIR/../$DEVEL_PREFIX.bpe.$EXP_SRC
  fi

  echo "Running $key"

  LC_ALL=C.UTF-8 cat $in_file |
    $EXP_MARIAN/marian-decoder -c $EXP_MODEL_DIR/model.npz.decoder.yml --log $TESTING_WORKSPACE/$key.log \
      -w 9000 -d $DEVICE_ID --mini-batch 20 --maxi-batch 10 >$prefix_out.bpe.out

  # BLEU
  cat $prefix_out.bpe.out | sed 's/\@\@ //g' | perl $EXP_MOSES_SCRIPTS_DIR/recaser/detruecase.perl | perl $EXP_MOSES_SCRIPTS_DIR/tokenizer/detokenizer.perl -l $EXP_TRG $ >$prefix_out.out
  cat $prefix_out.out | perl $EXP_MOSES_SCRIPTS_DIR/generic/multi-bleu-detok.perl $DATA_DIR/../$DEVEL_PREFIX.$EXP_TRG >$prefix_out.bleu

  #TER
  python2 /home/TILDE.LV/arturs.stafanovics/robust_NMT/src/modified_ter.py --input $prefix_out.out --ref $TESTING_WORKSPACE/$DEVEL_PREFIX.base.out -l en >$prefix_out.ter
  all_noises+=" $prefix_out.out"
done

python2 /home/TILDE.LV/arturs.stafanovics/robust_NMT/src/modified_ter.py --input $all_noises --ref $TESTING_WORKSPACE/$DEVEL_PREFIX.base.out -l en >$TESTING_WORKSPACE/overall.ter
