# Robust Neural Machine Translation: Modeling Orthographic and Interpunctual Variation
Repository contains code and evaluation data for experiments described in [Robust Neural Machine Translation: Modeling Orthographic and Interpunctual Variation](https://arxiv.org/abs/2009.05460)
# Citation 
```
@inproceedings{Bergmanis2020,
abstract = {Neural machine translation systems typically are trained on curated corpora and break when faced with non-standard orthography or punctuation. Resilience to spelling mistakes and typos, however, is crucial as machine translation systems are used to translate texts of informal origins, such as chat conversations, social media posts and web pages. We propose a simple generative noise model to generate adversarial examples of ten different types. We use these to augment machine translation systems' training data and show that, when tested on noisy data, systems trained using adversarial examples perform almost as well as when translating clean data, while baseline systems' performance drops by 2-3 BLEU points. To measure the robustness and noise invariance of machine translation systems' outputs, we use the average translation edit rate between the translation of the original sentence and its noised variants. Using this measure, we show that systems trained on adversarial examples on average yield 50{\%} consistency improvements when compared to baselines trained on clean data.},
address = {Kaunas, Lithuania},
author = {Bergmanis, Toms and Stafanovičs, Artūrs and Pinnis, Mārcis},
booktitle = {Human Language Technologies – The Baltic Perspective - Proceedings of the Ninth International Conference Baltic HLT 2020},
doi = {10.3233/FAIA200606},
pages = {80--86},
publisher = {IOS Press},
title = {{Robust Neural Machine Translation: Modeling Orthographic and Interpunctual Variation}},
year = {2020}
}
```
### Requirements
Noise generations script `add_noise.py` requires python3.
<br>
TER evaluation script `modified_ter.py` requires python2 with [pyter](https://github.com/roy-ht/pyter) library which can be installed by `pip install pyter`.

### Test data
Compressed test datasets can be found in `data/{language}/validation/validation.zip` it contains datasets with each type of noise and datasets used to calculate 10NT-TER.

#### Noise generation
Noise type is specified by providing space-separated function ids to `--functions` parameter

    latinize: 0
    phonetic latinize: 1
    add diacritic: 2
    delete letters: 3
    permute letters: 4
    introduce extra letters: 5
    confuse letters: 6
    sample substitute: 7
    remove punctuation: 8
    add comma: 9
    add punctuation: 10
When using `sample substitute` noise type you must also provide `--word-corpora` which is used to build model to sample similar words.
<br>
<br>
Usage example:


```
python src/add_noise.py \
    --functions 0 1 2 3 4 5 6 7 8 9 10 \
    --lang et \
    --word-corpora /home/train.tc.et \
    </home/newstest2018.tc.et > /home/newstest2018.tc.noise.et
```

### TER evaluation
[pyter](https://github.com/roy-ht/pyter) implementation is extended to support multiple hypothesis files.
<br>
Usage example:

```
python src/modified_ter.py \
    --input /home/10x_add-diacritic.lv /home/10x_confuse-letters.lv /home/10x_permute-letters.lv \
    --ref /home/10x_upscale.lv \
```

