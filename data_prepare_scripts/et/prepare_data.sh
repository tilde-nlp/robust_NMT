#!/bin/bash
set -eu
DIR=$(dirname "$(readlink -f "$0")")
PROJECT_ROOT=$(dirname "$(dirname "$DIR")")
EXP_SUBWORD_NMT_DIR=/home/TILDE.LV/marcis.pinnis/tools/prod-subword-nmt
cd $PROJECT_ROOT

LANG=et
CORPUS=train
VALIDATION=newsdev2018-enet

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
    ["full"]="0 1 2 4 6 7 8"
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
