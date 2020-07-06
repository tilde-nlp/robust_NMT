#!/bin/bash

set -eu

EXP="$1"
cd $EXP

. ./env.sh

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
  prefix_out=$TESTING_WORKSPACE/$DEVEL_PREFIX.$key

  if [[ $EXP =~ base ]]; then
    python2 /home/TILDE.LV/arturs.stafanovics/robust_NMT/src/modified_ter.py --input $prefix_out.out --ref $DATA_DIR/$DEVEL_PREFIX.$EXP_TRG -l en >$prefix_out.ter
  else
    python2 /home/TILDE.LV/arturs.stafanovics/robust_NMT/src/modified_ter.py --input $prefix_out.out --ref $DATA_DIR/../$DEVEL_PREFIX.$EXP_TRG -l en >$prefix_out.ter
  fi
  all_noises+=" $prefix_out.out"
done

if [[ $EXP =~ base ]]; then
  python2 /home/TILDE.LV/arturs.stafanovics/robust_NMT/src/modified_ter.py --input $all_noises --ref $DATA_DIR/$DEVEL_PREFIX.$EXP_TRG -l en >$TESTING_WORKSPACE/overall.ter
else
  python2 /home/TILDE.LV/arturs.stafanovics/robust_NMT/src/modified_ter.py --input $all_noises --ref $DATA_DIR/../$DEVEL_PREFIX.$EXP_TRG -l en >$TESTING_WORKSPACE/overall.ter
fi
