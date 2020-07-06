"""Spelling Corrector in Python 3; see http://norvig.com/spell-correct.html

Copyright (c) 2007-2016 Peter Norvig
MIT license: www.opensource.org/licenses/mit-license.php
"""

################ Spelling Corrector 

import re
from collections import Counter
from random import choice

WORDS = {}
lang = ""


def init_lang(language):
    global lang
    lang = language


def get_words():
    global WORDS
    global lang

    if len(WORDS) == 0:
        def words(text): return re.findall(r'\w+', text.lower())

        file = {'lv': '/home/TILDE.LV/arturs.stafanovics/robust_NMT/data/lv/corpus.tc.lv',
                'lt': '/home/TILDE.LV/arturs.stafanovics/robust_NMT/data/lt/train.tok.tc.lt',
                'et': '/home/TILDE.LV/arturs.stafanovics/robust_NMT/data/et/train.tc.et'}[lang]

        WORDS = Counter(words(open(file).read()))
        WORDS = Counter({x: WORDS[x] for x in WORDS if WORDS[x] >= 10})
    return WORDS


def P(word, N=-1):
    if N == -1:
        N = sum(get_words().values())
    "Probability of `word`."
    return get_words()[word] / N


def correction(word):
    "Most probable spelling correction for word."

    return max(candidates(word), key=P)


def candidates(word):
    "Generate possible spelling corrections for word."
    # return (known([word]) or known(edits1(word)) or known(edits2(word)) or [word])
    return known(edits1(word))


def sampleSubstitute(word):
    population = list(candidates(word))
    return choice(population)


def known(words):
    "The subset of `words` that appear in the dictionary of WORDS."
    return set(w for w in words if w in get_words())


def edits1(word):
    "All edits that are one edit away from `word`."
    letters = 'abcdefghijklmnopqrstuvwxyzāčēģīķļņšūž'
    splits = [(word[:i], word[i:]) for i in range(len(word) + 1)]
    deletes = [L + R[1:] for L, R in splits if R]
    transposes = [L + R[1] + R[0] + R[2:] for L, R in splits if len(R) > 1]
    replaces = [L + c + R[1:] for L, R in splits if R for c in letters]
    inserts = [L + c + R for L, R in splits for c in letters]
    return set(deletes + transposes + replaces + inserts)


def edits2(word):
    "All edits that are two edits away from `word`."
    return (e2 for e1 in edits1(word) for e2 in edits1(e1))


if __name__ == '__main__':
    pass
