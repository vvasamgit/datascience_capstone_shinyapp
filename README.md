

DsCsCommon.R
  Declares global variables and common functions for
  
  * Capturing time
  * Memory management
  * Gather file information
  * Gather file line count and word count
  * Create quanteda tokens, dfm
  * Create ngram top features bar plot
  
DsCsEa.R

  * Creates uni, bi and trigram top features bar plot and shows plot with file information

DsCsPrepare.R

  * Reads files and cleanses text by remobing non alphabatic characters
  * Creates quanted corpus, token objects and saves object to file system as files

DsCsNgrams.R

  * Reads token R object files 
  * Creates N-grams ( uni, bi, tri) and save the n-gram objects to file system

DsCsCreateModelGrams.R

 * Reads n-gram object files and creates document feature matrix (dfm)
 * Trims DFM to have words with minimum frequency and saves the DFM files
 * Reads DFM files and create a data.frame object with n-gram words as features and saves them as rds files.
 
DsCsFindNextWord.R
 
 * Reads data.fram object with n-grame word features
 * Computes unigram probaility
 * Computes Kneser-Ney interpolation probability in b-gram and tri-gram
 * Creates functions for searching a match for the given inpput word in tri, bi and unigrams
 * If there is no match returns top unigram words.
 
 dscs_shinyapp
 
  * Shiny app source code for next word prediction 
  
RPresentation
 
  * R presentation file for data science capstone project
 