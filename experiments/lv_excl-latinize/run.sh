#!/bin/bash
. ./env.sh

mkdir -p $EXP_MODEL_DIR

if [ ! -f  $EXP_DICT_SRC ]; then
    cat $EXP_TRAIN_SRC $EXP_TRAIN_TRG | $EXP_MARIAN/marian-vocab --max-size $EXP_VOCAB_SIZE > $EXP_DICT_SRC
fi

$EXP_MARIAN/marian --devices 3 4 \
  --type transformer \
  --model $EXP_MODELS_SAVETO \
  --train-sets $EXP_TRAIN_SRC $EXP_TRAIN_TRG \
  --vocabs $EXP_DICT_SRC $EXP_DICT_TRG \
  --max-length 128 \
  --mini-batch-fit \
  --workspace 9000 \
  --maxi-batch 200 \
  --early-stopping 10 \
  --valid-freq 1000 \
  --save-freq 2000 \
  --disp-freq 100 \
  --keep-best \
  --valid-metrics cross-entropy translation \
  --valid-sets $EXP_VALID_SRC $EXP_VALID_TRG \
  --valid-script-path $EXP_VALID_SCRIPT \
  --log $EXP_MODEL_DIR/train.log \
  --valid-log $EXP_MODEL_DIR/valid.log \
  --seed 347155 \
  --exponential-smoothing \
  --normalize 0.6 \
  --beam-size 12 \
  --quiet-translation \
  --valid-translation-output $EXP_MODEL_DIR/valid.output.txt \
  --valid-mini-batch 16 \
  --enc-depth 6 \
  --dec-depth 6 \
  --transformer-heads 8 \
  --transformer-preprocess d \
  --transformer-postprocess-emb d \
  --transformer-postprocess dan \
  --optimizer-delay 4 \
  --learn-rate 0.0003 \
  --lr-warmup 16000 \
  --lr-decay-inv-sqrt 16000 \
  --lr-report \
  --clip-norm 5 \
  --tied-embeddings-all \
  --sync-sgd \
  --transformer-guided-alignment-layer 1 \
  --guided-alignment-cost mse \
  --guided-alignment-weight 0.1 \
  --transformer-dropout 0.1 \
  --transformer-dropout-attention 0.1 \
  --transformer-dropout-ffn 0.1 \
  --optimizer adam \
  --optimizer-params 0.9 0.98 1e-09
