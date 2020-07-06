import random
import sys
import string
import argparse
import spell

lang = ""

LV_PHONETIC_MAPPING = dict(zip([l for l in "āčēģīķļņšūž" + "āčēģīķļņšūž".upper()],
                               ["aa", "ch", "ee", "gj", "ii", "kj", "lj", "nj", "sh", "uu", "zh"] + list(map(
                                   lambda x: x.capitalize(), ["aa", "ch", "ee",
                                                              "gj", "ii", "kj",
                                                              "lj", "nj", "sh",
                                                              "uu", "zh"]))))
LV_REVERSE_MAPPING = dict(zip("acegiklnsuz" + "acegiklnsuz".upper(), "āčēģīķļņšūž" + "āčēģīķļņšūž".upper()))
LV_MAPPING = dict(zip("āčēģīķļņšūž" + "āčēģīķļņšūž".upper(), "acegiklnsuz" + "acegiklnsuz".upper()))

ET_REVERSE_MAPPING = dict(zip("szoaou" + "szoaou".upper(), "šžõäöü" + "šžõäöü".upper()))
ET_MAPPING = dict(zip("šžõäöü" + "šžõäöü".upper(), "szoaou" + "szoaou".upper()))

LT_REVERSE_MAPPING = dict(zip("aceeisuuz" + "aceeisuuz".upper(), "ąčęėįšųūž" + "ąčęėįšųūž".upper()))
LT_MAPPING = dict(zip("ąčęėįšųūž" + "ąčęėįšųūž".upper(), "aceeisuuz" + "aceeisuuz".upper()))

MOSES_TOKENIZER_ESCAPE_CHARACTERS = {
    '&': '&amp;',
    '|': '&#124;',
    '<': '&lt;',
    '>': '&gt;',
    '\'': '&apos;',
    '"': '&quot;',
    '[': '&#91;',
    ']': '&#93;'
}

PUNCTUATION_TOKENS = [
                         s if s not in MOSES_TOKENIZER_ESCAPE_CHARACTERS else MOSES_TOKENIZER_ESCAPE_CHARACTERS[s] for s
                         in
                         string.punctuation] + ['@-@']


class StrictList(list):
    """List subclass, rejects appending falsey items and negative indexing.
    Extends __getitem__ to raise IndexErrors with negative indices.
    Extends __append__ to ignore append arguments that are falsey.
    """

    def __getitem__(self, n):
        if n < 0:
            raise IndexError("Strict lists don't accept negative indexing.")
        return list.__getitem__(self, n)

    def append(self, n):
        if not n:
            return
        return list.append(self, n)


def delete_letters(word):
    index = random.randint(1, len(word) - 1)
    while not word[index].isalpha():
        index = random.randint(1, len(word) - 1)
    return word[0: index] + word[index + 1:]


def permute_letters(word):
    start_index = 1
    if word[0].isupper():
        start_index = 2

    if start_index > len(word) - 1:
        return word

    index = random.randint(start_index, len(word) - 1)
    while not (word[index].isalpha() and word[index - 1].isalpha()):
        index = random.randint(start_index, len(word) - 1)
    return word[0: index - 1] + word[index] + word[index - 1] + word[index + 1:]


def introduce_extra_letters(word):
    index = random.randint(0, len(word) - 1)
    while not word[index].isalpha():
        index = random.randint(0, len(word) - 1)
    if random.random() < 0.5:  # double the letter
        return word[0: index] + word[index] + word[index] + word[index + 1:]
    else:  # adds a nearby letter
        addition = random.choice(neighbour_keys(word[index]))
        if word[index].islower():
            return word[0: index + 1] + addition + word[index + 1:]
        else:
            return word[0: index + 1] + addition.upper() + word[index + 1:]


def confuse_letters(word):
    index = random.randint(0, len(word) - 1)
    while not word[index].isalpha():
        index = random.randint(0, len(word) - 1)
    confusion = random.choice(neighbour_keys(word[index]))
    if word[index].islower():
        return word[0: index] + confusion + word[index + 1:]
    else:
        return word[0: index] + confusion.upper() + word[index + 1:]


def latinize(word):
    mapping = {'lv': LV_MAPPING, 'lt': LT_MAPPING, 'et': ET_MAPPING}[lang]
    word = "".join([mapping[l] if l in mapping else l for l in word])
    return word


def phonetic_latinize(word):
    if lang in {'et', 'lt'}:
        return word
    return latinize(word)


def add_diacritic(word):
    mapping = {'lv': LV_REVERSE_MAPPING, 'lt': LT_REVERSE_MAPPING, 'et': ET_REVERSE_MAPPING}[lang]

    indexes = [i for i, l in enumerate(word) if l in mapping]
    if len(indexes) > 0:
        index = random.choice(indexes)
        return word[0: index] + mapping[word[index]] + word[index + 1:]
    return word


def remove_punctuation(sentence):
    return " ".join([item for item in sentence.split() if item not in PUNCTUATION_TOKENS])


def add_punctuation(sentence):
    sentence = sentence.split(' ')
    sentence.insert(random.randint(0, len(sentence) - 1), random.choice(PUNCTUATION_TOKENS))
    return ' '.join(sentence)


def add_comma(sentence):
    sentence = sentence.split(' ')
    sentence.insert(random.randint(0, len(sentence) - 1), ',')
    return ' '.join(sentence)


def neighbour_keys(k):
    valid_chars = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
                   'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
    keyboard = StrictList([
        StrictList(['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']),
        StrictList([None, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', ]),
        StrictList([None, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', ]),
    ])

    def check(c):
        """Return only valid characters."""
        return c if c in valid_chars else ''

    """Return a list of keys physically near character 'k' on the keyboard."""
    k = latinize(k.lower())
    keys = StrictList()

    index = []

    for i, row in enumerate(keyboard):
        if k in row:
            index.append(i)
            # Detect whether to go one column forward or back,
            # based on which row of the keyboard this button is in.
            offset = 1 if i % 2 == 0 else -1
            index.append(row.index(k))
            break
    else:
        # print ("Invalid Key: {}".format(k))
        return [k]

    # Iterate over the key's row, the row above and the one below,
    # pass an IndexError if the referenced index is non existent.
    for val in ([0, -1], [0, 1], [-1, 0], [-1, offset], [+1, 0], [1, offset],):
        try:
            neighbour_key = keyboard[index[0] + val[0]][index[1] + val[1]]
            keys.append(check(neighbour_key))
        except IndexError:
            pass
    return keys


all_noise_functions = [(latinize, "<0>"), (phonetic_latinize, "<1>"), (add_diacritic, "<2>"),
                       (delete_letters, "<3>"),
                       (permute_letters, "<4>"), (introduce_extra_letters, "<5>"), (confuse_letters, "<6>"),
                       (spell.sampleSubstitute, "<7>"), (remove_punctuation, "<8>"), (add_comma, "<9>"),
                       (add_punctuation, "<10>")]



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--functions', nargs='+', required=False, type=int, help="""
    latinize: 0
    phonetic_latinize: 1
    addDiacritic: 2
    delete_letters: 3
    permute_letters: 4
    introduce_extra_letters: 5
    confuse_letters: 6
    spell.sampleSubstitute: 7
    remove_punctuation: 8
    add_coma: 9
    add_punctuation: 10
    """)
    parser.add_argument('--lang', required=True, type=str)
    args = parser.parse_args()
    global lang
    lang = args.lang
    spell.init_lang(lang)

    noise_functions = [x for index, x in enumerate(all_noise_functions) if index in args.functions]
    assert len(noise_functions) != 0, f"Provide at least one valid noise function id, given: {args.functions}"

    i = 0
    for sentence in sys.stdin:
        sentence = sentence.strip()
        noise_function, tag = noise_functions[i % len(noise_functions)]
        words = sentence.split()
        if tag in {'<0>', '<1>', '<8>', '<9>', '<10>'}:
            print(noise_function(sentence))
        elif tag == '<7>':
            applicableWords = [(i, w) for i, w in enumerate(words) if w.isalpha() and len(spell.candidates(w)) != 0]
            if len(applicableWords) == 0:
                print(sentence)
            else:
                index, w = random.choice(applicableWords)
                print(" ".join(words[0: index] + [spell.sampleSubstitute(words[index])] + words[index + 1:]))
        else:
            applicableWords = [(i, w) for i, w in enumerate(words) if w.isalpha() and len(w) > 2]
            if len(applicableWords) == 0:
                print(sentence)
            else:
                index, w = random.choice(applicableWords)
                print(" ".join(words[0:index] + [noise_function(w)] + words[index + 1:]))
        i += 1


if __name__ == "__main__":
    main()
