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
  mkdir -p data/$LANG
  cd data/$LANG
  operations=25000
  threshold=50

  # Build BPE vocabulary
  python3 "$EXP_SUBWORD_NMT_DIR"/learn_joint_bpe_and_vocab.py --input "$CORPUS".tc.en "$CORPUS".tc."$LANG" -s $operations -o bpe.codes --write-vocabulary bpe.vocab.en bpe.vocab."$LANG"

  # base
  for file in "$VALIDATION" "$CORPUS"; do
    python3 "$EXP_SUBWORD_NMT_DIR"/apply_bpe.py -c bpe.codes --vocabulary bpe.vocab.en --vocabulary-threshold $threshold <"$file".tc.en >"$file".tc.bpe.en
    python3 "$EXP_SUBWORD_NMT_DIR"/apply_bpe.py -c bpe.codes --vocabulary bpe.vocab."$LANG" --vocabulary-threshold $threshold <"$file".tc."$LANG" >"$file".tc.bpe."$LANG"
  done


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
    ["excl-latinize"]="1 2  4  6 7 8 "
    ["excl-phonetic-latinize"]="0 2  4  6 7 8 "
    ["excl-add-diacritic"]="0 1  4  6 7 8 "
    ["excl-permute-letters"]="0 1 2   6 7 8 "
    ["excl-confuse-letters"]="0 1 2  4  7 8 "
    ["excl-sample-substitute"]="0 1 2  4  6 8 "
    ["excl-remove-punctuation"]="0 1 2  4  6 7 "
    ["full"]="0 1 2 4 6 7 8"
    ["add-punctuation"]="10"
  )

  for key in "${!functions[@]}"; do
    value=${functions[$key]}
    mkdir -p $key
    (
      python "$PROJECT_ROOT"/src/add_noise.py --functions $value --lang $LANG <$CORPUS.tc.$LANG >$key/$CORPUS.tc.$LANG
      python "$EXP_SUBWORD_NMT_DIR"/apply_bpe.py -c bpe.codes --vocabulary bpe.vocab.$LANG --vocabulary-threshold $threshold <$key/$CORPUS.tc.$LANG >$key/$CORPUS.tc.bpe.$LANG
      cat $CORPUS.tc.bpe.$LANG >>$key/$CORPUS.tc.bpe.$LANG
      cat $CORPUS.tc.bpe.en $CORPUS.tc.bpe.en >$key/$CORPUS.tc.bpe.en
      (
        cd $key
        ln -sf ../$VALIDATION.tc.bpe.en $VALIDATION.tc.bpe.en
        ln -sf ../$VALIDATION.tc.en $VALIDATION.tc.en
        ln -sf ../$VALIDATION.tc.bpe.$LANG $VALIDATION.tc.bpe.$LANG
      )

    ) &

  done
  wait
)
