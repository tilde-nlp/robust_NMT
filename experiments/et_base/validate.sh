#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/env.sh

ref=$EXP_PROCESS_VALID_TRG
	

cat $1 \
    | sed 's/\@\@ //g' \
    | $EXP_MOSES_SCRIPTS_DIR/generic/multi-bleu.perl $ref \
	| sed -r 's/BLEU = ([0-9.]+),.*/\1/'
