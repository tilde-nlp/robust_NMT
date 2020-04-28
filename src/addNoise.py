import random
import sys
import string
import spell

def deleteLetters(word):
  index = random.randint(1,len(word)-1)
  while not word[index].isalpha():
      index = random.randint(1,len(word)-1)
  return word[0 : index ] + word[index + 1 : ]

def permuteLetters(word):
  START_INDEX = 1
  if word[0].isupper():
    START_INDEX = 2

  if START_INDEX > len(word): # or not checkAplicability(word[START_INDEX:]):
    return word
  index = random.randint(START_INDEX,len(word)-1)
  while not (word[index].isalpha() and word[index-1].isalpha()):
    index = random.randint(START_INDEX,len(word)-1)
  return word[0 : index-1] + word[index] + word[index-1] + word[index + 1 : ]

def introduceExtraLetters(word):
  index = random.randint(0,len(word)-1)
  while not word[index].isalpha():
      index = random.randint(0,len(word)-1)
  if (random.random() < 0.5): # double the letter
    return word[0 : index] + word[index] + word[index] + word[index + 1 : ]
  else: # adds a nearby letter
    addition = random.choice(neighbourKeys(word[index]))
    if word[index].islower():
      return word[0 : index+1] + addition + word[index + 1 : ]
    else:
      return word[0 : index+1] + addition.upper() + word[index + 1 : ]

def confuseLetters(word):
  index = random.randint(0,len(word)-1)
  while not word[index].isalpha():
      index = random.randint(0,len(word)-1)
  confussion = random.choice(neighbourKeys(word[index]))
  if word[index].islower():
    return word[0 : index] + confussion + word[index + 1 : ]
  else:
    return word[0 : index] + confussion.upper() + word[index + 1 : ]


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

LV_MAPPING = dict(zip("āčēģīķļņšūž"+"āčēģīķļņšūž".upper(), "acegiklnsuz"+"acegiklnsuz".upper()))
def latinize(word, mapping=LV_MAPPING):
  word = "".join([mapping[l] if l in mapping else l for l in word])
  return word

LV_PHONETIC_MAPPING = dict(zip([l for l in "āčēģīķļņšūž"+"āčēģīķļņšūž".upper()], ["aa", "ch", "ee", "gj", "ii", "kj","lj", "nj", "sh", "uu","zh"]+ [r.capitalize() for r in ["aa", "ch", "ee", "gj", "ii", "kj","lj", "nj", "sh", "uu","zh"]]))

def phoneticLatinize(word, mapping=LV_PHONETIC_MAPPING):
  return latinize(word, LV_PHONETIC_MAPPING)

LV_REVERSE_MAPPING = dict(zip("acegiklnsuz"+"acegiklnsuz".upper(),"āčēģīķļņšūž"+"āčēģīķļņšūž".upper()))

def addDiacritic(word,mapping=LV_REVERSE_MAPPING):
  indexes = [i for i, l in enumerate(word) if l in mapping]
  if len(indexes) > 0:
    index = random.choice(indexes)
    return word[0 : index] + mapping[word[index]] + word[index + 1 : ]
  return word


def removePunctuation(sentence):
    return " ".join([item for item in sentence.split() if item not in string.punctuation])

def neighbourKeys(k): 
  validChars = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
              'p','q','r','s','t','u','v','w','x','y','z'}
  keyboard = StrictList([
                   StrictList(['q','w','e','r','t','y','u','i','o','p']),
                   StrictList([None,'a','s','d','f','g','h','j','k','l',';',]),
                   StrictList([None,'z','x','c','v','b','n','m',',','.',]),
                   ]) 
  def check(c):
    """Return only valid characters."""
    return c if c in validChars else ''
   
  """Return a list of keys physically near character 'k' on the keyboard."""
  k = latinize(k.lower())
  keys = StrictList()

  index = []

  for i,row in enumerate(keyboard):
    if k in row:
      index.append(i)
      # Detect whether to go one column forward or back,
      # based on which row of the keyboard this button is in.
      offset = 1 if i % 2 == 0 else -1
      index.append(row.index(k))
      break
  else:
    #print ("Invalid Key: {}".format(k))
    return [k]

  # Iterate over the key's row, the row above and the one below,
  # pass an IndexError if the referenced index is non existent.
  for val in ([0,-1], [0, 1],[-1, 0], [-1, offset], [+1, 0], [ 1, offset],):
    try:
      neighbourKey = keyboard[index[0] + val[0]][index[1] + val[1]]
      keys.append(check(neighbourKey))
    except IndexError:
      pass
  return keys

"""def checkAplicability(sentence):
  try:
    return any([True for (a,b) in zip(word.split([:-1]), word[1:]) if a.isalpha() and b.isalpha()])
  except:
    return False
"""

noiseFunctions = [(latinize,"<0>") , (phoneticLatinize,"<1>"), (addDiacritic,"<2>"), (deleteLetters,"<3>"), (permuteLetters,"<4>"), (introduceExtraLetters,"<5>"), (confuseLetters,"<6>"), (spell.sampleSubstitute, "<7>"), (removePunctuation, "<8>")]


i = 0
for sentence in sys.stdin:
  sentence = sentence.strip()
  functionID = i % len(noiseFunctions)
  noiseFunction, tag = noiseFunctions[functionID]
  words = sentence.split()
  if functionID == 0 or functionID == 1 or functionID == 8:
    print(noiseFunction(sentence))
  elif functionID == 7:
    applicableWords = [(i, w) for i, w in enumerate(words) if w.isalpha() and len(spell.candidates(w)) != 0]
    if applicableWords == []:
      print(sentence)
    else:
      index, w = random.choice(applicableWords)
      print(" ".join(words[0 : index] + [spell.sampleSubstitute(words[index])] + words[index+1 : ]))
  else:
    applicableWords = [(i, w) for i, w in enumerate(words) if w.isalpha() and len(w) > 2]
    if applicableWords == []:
      print(sentence)
    else:
      index, w = random.choice(applicableWords)
      print(" ".join(words[0:index] + [noiseFunction(w)] + words[index+1 : ]))
  i += 1