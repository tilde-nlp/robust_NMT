#!/bin/bash
set -eu
DIR=$(dirname "$(readlink -f "$0")")
PROJECT_ROOT=$(dirname "$(dirname "$DIR")")
cd $PROJECT_ROOT

mkdir -p data/lv

(
  cd data/lv
  # Dowload parralel corpus
  wget http://data.statmt.org/wmt17/translation-task/preprocessed/lv-en/corpus.tc.en.gz
  gunzip corpus.tc.en.gz
  wget http://data.statmt.org/wmt17/translation-task/preprocessed/lv-en/corpus.tc.lv.gz
  gunzip corpus.tc.lv.gz
  curl http://data.statmt.org/wmt17/translation-task/preprocessed/lv-en/dev.tgz | tar xvzf -
  rm *.sgm
  curl http://data.statmt.org/wmt17/translation-task/preprocessed/lv-en/true.tgz | tar xvzf -
)

