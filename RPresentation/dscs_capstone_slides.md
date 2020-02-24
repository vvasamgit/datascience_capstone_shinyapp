Data Science Capstone Next Word Prediction Application
========================================================
author: Venkata Vasam 
date: 
autosize: true

Exploratory Data Analysis
========================================================
* Text Documents Corpus Source : https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip
* Read files and create line count and word counts
*  Quanteda Natural Language Processing (NLP)library API for corpus, tokens, N-Grams and Document Feature Matrix
![Capstone Exploratory Analyis](dscea.jpg)

Next Word Prediction Application Flow
========================================================
* Data preparation process/job 
  - Read files, create and save object files for 
     + corpus and tokens
     + N-grams and trimmed dfm with word frequency more than 3 words, 
     + Create data.table object with n-gram words for uni, bi and tri-grams
     + Create probabilities for normalized Maximum Likelihood Estimation and Interpolated Kneser-Ney smoothing 
     + Save final model data.table objects for later use in Shiny application
* Shiny web application
    - Reads final model data.table objects form file 
    - Implement search algorithm for retrieving next word.
    - Always returns 5 words with top probability
    
Next Prediction Model Algorithm -Kneser-Ney Smoothing
========================================================
* N-Gram models for unigram, bigram and trigram with counts and probability.
* Probability of next word using previous word(Markov) and Normalized Maximum Likelihood Estimation : $$P(w_n/w_{1}^{n-1})=P(w_n/w_{n-1})=C(w_{n-1}w_n)/C(w_{n-1})$$
* Interploated Kneser-Ney smoothing :$$P_{KN}(w_i/w_{i-1}=max(c(w_{i-1}w_i)-d,0)/c(w_{i-1})+\lambda(w_{i-1})P_{continuation}(w_i))$$

  $$\lambda(w_{i-1})=d/c(w_{i-1}) | {w:c(w_{i-1,w}) >0 }| , d=0.75$$ where $$c(w_{i-1})$$ is previous word count in prev n-gram and $$c(w_{i-1,w})$$ prev word count in current n-gram.


Final Model Features
========================================================
- BiGram model features   

```
   word1 word2 count prevGramPrevWcount         prob prevWcount
1:   the   the  1710            4742818 0.0003605451      44254
      w2uniprob          pkn
1: 4.513654e-06 0.0003604186
```
- TriGram model features  

```
   word1 word2 word3 count prevGramPrevWcount       prob prevWcount
1:   the   the  best    23               1710 0.01345029         99
          bipkn        pkn
1: 0.0003604186 0.01302735
```

 prevGramPrevWcount is $$c(w_{i-1}): previous word (n-1) count in prev n-gram$$
 
 prevWcount is $$c(w_{i-1,w}) : previous(n-1) word count in current n-gram $$

Find Next Word Algorithm using Final Model Features
========================================================
- Back off Algorithm using Trigram, Bigram Kneser-Ney probability and Unigram probability 
  + Get last two input words and check in Trigram for the match, if there is a match return matched words
  + if there is no match in Trigram check Bigram. if there is a match return matched words
  + if there is no match in Bigram check Unigram. if there is a match return matched words
  + if there is no match in Unigram return sample unigrams with highest probability

Application Usage Instructions
========================================================
The application URL is: https://vvasam.shinyapps.io/dscs_shinyapp/

![](dscswebapp-usageguide.jpg)

References 
========================================================
* Source code Git repository for the Data science Capstone Project: 
  https://github.com/vvasamgit/datascience_capstone_shinyapp
* Text mining infrastructure in R: 
   https://www.jstatsoft.org/article/view/v025i05
*  CRAN Task View: Natural Language Processing: 
        https://cran.r-project.org/web/views/NaturalLanguageProcessing.html
* Speech and Language Processing (3rd ed. draft):
  https://web.stanford.edu/~jurafsky/slp3/
  N-GRAMS: 
    https://web.stanford.edu/~jurafsky/slp3/3.pdf
* Data Science Specialization Community Mentor Content Repository:
  https://github.com/lgreski/datasciencectacontent
* The Elements of Statistical Learning:
    https://web.stanford.edu/~hastie/ElemStatLearn/
* Quanteda: Quantitative Analysis of Textual Data
https://quanteda.io/
