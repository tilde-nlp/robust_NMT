import random
import sys
import spell

def checkAplicability(word):
  try:
    return any([True for (a,b) in zip(word[:-1], word[1:]) if a.isalpha() and b.isalpha()])
  except:
    return False


def applyNoiseFunction(sentence):
  try:  
      applicableWords = [(i, w) for i, w in enumerate(sentence.split()) if w.isalpha() and len(spell.candidates(w)) != 0]
      if applicableWords == []:
          return sentence.strip()
      else:
        lc = sentence.split()
        index, w = random.choice(applicableWords)
        #print(" ".join([tag] + lc[0:index] + [noiseFunction(lc[index])] + lc[index+1 : ]))
        return " ".join(lc[0:index] + [spell.sampleSubstitute(lc[index])] + lc[index+1 : ])
  except:
    print(sentence.strip())

i = 0
for sentence in sys.stdin:
  
  if checkAplicability(sentence):
      print(i)
      #applyNoiseFunction(sentence)
  else:
    print(i)
    #print(sentence.strip())
