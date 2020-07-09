#!/bin/bash
set -eu
DIR=$(dirname "$(readlink -f "$0")")
PROJECT_ROOT=$(dirname "$(dirname "$DIR")")
EXP_SUBWORD_NMT_DIR=/home/TILDE.LV/marcis.pinnis/tools/prod-subword-nmt
cd $PROJECT_ROOT

LANG=lv
CORPUS=corpus
VALIDATION=newsdev2017

(
  cd data/lv
  threshold=50

  declare -A functions=(
    ["latinize"]="0"
    ["phonetic-latinize"]="1"
    ["add-diacritic"]="2"
    ["delete-letters"]="3"
    ["permute-letters"]="4"
    ["introduce-extra-letters"]="5"
    ["confuse-letters"]="6"
    ["sample-substitute"]="7"
    ["remove-punctuation"]="8"
    ["add-comma"]="9"
    ["add-punctuation"]="10"
  )

  mkdir -p validation

  for key in "${!functions[@]}"; do
    value=${functions[$key]}
    (
      python3 "$PROJECT_ROOT"/src/add_noise.py --functions $value <$VALIDATION.tc.lv >validation/$VALIDATION.tc.$key.$LANG
      python3 "$EXP_SUBWORD_NMT_DIR"/apply_bpe.py -c bpe.codes --vocabulary bpe.vocab.$LANG --vocabulary-threshold $threshold <validation/$VALIDATION.tc.$key.$LANG >validation/$VALIDATION.tc.$key.bpe.$LANG
    ) &
  done
  wait

  declare -A gen_10x_functions=(
    ["10x_add-diacritic"]="2"
    ["10x_permute-letters"]="4"
    ["10x_confuse-letters"]="6"
    ["10x_sample-substitute"]="7"
  )
  for key in "${!gen_10x_functions[@]}"; do
    value=${gen_10x_functions[$key]}
    (
      for i in {1..10}; do
        python3 "$PROJECT_ROOT"/src/add_noise.py --functions $value <$VALIDATION.tc.lv >>validation/$VALIDATION.tc.$key.$LANG --lang $LANG
      done
      python3 "$EXP_SUBWORD_NMT_DIR"/apply_bpe.py -c bpe.codes --vocabulary bpe.vocab.$LANG --vocabulary-threshold $threshold <validation/$VALIDATION.tc.$key.$LANG >validation/$VALIDATION.tc.$key.bpe.$LANG
    )&
  done
  wait
)
