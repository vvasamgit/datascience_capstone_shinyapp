
source("DsCsCommon.R")


startTime <- captureStartTime()
gcDet<-calcGc()


nGram<-1

nwmFilePattern<-paste0(nwmFilePrefix,nGram, "_(.)*.rds")

nwmFile<-list.files(nwmDirHome,pattern=nwmFilePattern)

nwm<-readRDS(paste0(nwmDirHome,.Platform$file.sep,nwmFile[1]))

uniGramDT <- nwm

timeTaken <- captureTimeTaken(startTime, paste0(nGram, " gram next word model load "))
rm(nwmFilePattern)
rm(nwmFile)
rm(nwm)

gcDet<-calcGc()

nGram<-2

nwmFilePattern<-paste0(nwmFilePrefix,nGram, "_(.)*.rds")

nwmFile<-list.files(nwmDirHome,pattern=nwmFilePattern)

nwm<-readRDS(paste0(nwmDirHome,.Platform$file.sep,nwmFile[1]))

biGramDT <- nwm

rm(nwmFilePattern)
rm(nwmFile)
rm(nwm)

timeTaken <- captureTimeTaken(startTime, paste0(nGram, " gram next word model load "))
gcDet<-calcGc()


nGram<-3

nwmFilePattern<-paste0(nwmFilePrefix,nGram, "_(.)*.rds")

nwmFile<-list.files(nwmDirHome,pattern=nwmFilePattern)

nwm<-readRDS(paste0(nwmDirHome,.Platform$file.sep,nwmFile[1]))

triGramDT <- nwm

rm(nwmFilePattern)
rm(nwmFile)
rm(nwm)

timeTaken <- captureTimeTaken(startTime, paste0(nGram, " gram next word model load "))
gcDet<-calcGc()


uniCount<-nrow(uniGramDT)

uniGramDT<-uniGramDT[,prob:=.N/uniCount, by=word1]


biGramDT<-biGramDT[uniGramDT,.(word1, word2, count,i.count), on="word1"]

head(biGramDT,5)

setnames(biGramDT,old="i.count", new="prevcount")

biGramDT<-biGramDT[,prob:=count/prevcount]

biGramDT<-biGramDT[,prevWcount:=.N,by=word1]


knd<-0.75

biGramDT<-biGramDT[uniGramDT,.(word1, word2, count,prevcount,prob,prevWcount, i.prob), on=c("word2==word1")]

setnames(biGramDT,old="i.prob", new="w2uniprob")

head(biGramDT,5)

#pkn -pkn(Wi/Wi-1)=max(c(Wi-1wi-d),0)/c(Wi-1)+lambda(Wi-1)*pcn(wi). Where  lambda(Wi-1)=d/c(wi-1){w:c(wi-1,w)>0}
#c(Wi-1wi-d) - bigram count, d - discount, c(wi-1) unigram wi-1 coun, c(wi-1,w): first word count of bigram
#

biGramDT[,pkn:=((count-knd)/prevcount+knd/prevcount*prevWcount*w2uniprob)]


triGramDT<-triGramDT[biGramDT,.(word1, word2, word3, count,i.count), on=.(word1,word2)]

head(triGramDT)

setnames(triGramDT,old="i.count", new="prevcount")

triGramDT<-triGramDT[,prob:=count/prevcount]

triGramDT<-triGramDT[,prevWcount:=.N,by=.(word1,word2)]

triGramDT<-triGramDT[biGramDT,.(word1, word2,word3, count,prevcount,prob,prevWcount, i.pkn), on=.(word1,word2)]

setnames(triGramDT,old="i.pkn", new="bipkn")

#pkn -pkn(Wi/Wi-1)=max(c(Wi-1wi-d),0)/c(Wi-1)+lambda(Wi-1)*pcn(wi). Where  lambda(Wi-1)=d/c(wi-1){w:c(wi-1,w)>0}
#c(Wi-1wi-d) - bigram count, d - discount, c(wi-1) unigram wi-1 coun, c(wi-1,w): first word count of bigram
#
triGramDT[,pkn:=((count-knd)/prevcount+knd/prevcount*prevWcount*bipkn)]

head(uniGramDT)

uniGramDT <- uniGramDT[order(-prob)]

saveRDS(uniGramDT,paste0(dataDirHome,.Platform$file.sep,nwmDir,.Platform$file.sep,nwmFinalFilePrefix,"1","_", capstoneFileSuffix, ".rds") )

saveRDS(biGramDT,paste0(dataDirHome,.Platform$file.sep,nwmDir,.Platform$file.sep,nwmFinalFilePrefix,"2","_", capstoneFileSuffix, ".rds") )

saveRDS(triGramDT,paste0(dataDirHome,.Platform$file.sep,nwmDir,.Platform$file.sep,nwmFinalFilePrefix,"3","_", capstoneFileSuffix, ".rds") )

uniGrams <- function(n = 5) {  
  return(sample(uniGramDT[, word1], size = n))
}


biGrams <- function(w1, n = 5) {
  pwords <- biGramDT[word1==w1][order(-pkn)]
  if (any(is.na(pwords)))
    return(uniGrams(n))
  if (nrow(pwords) > n)
    return(pwords[1:n, word2])
  count <- nrow(pwords)
  unWords <- uniGrams(n)[1:(n - count)]
  return(c(pwords[, word2], unWords))
}

triGrams <- function(w1, w2, n = 5) {
  pwords <- triGramDT[word1==w1 & word2==w2][order(-pkn)]
  if (any(is.na(pwords)))
    return(biGrams(w2, n))
  if (nrow(pwords) > n)
    return(pwords[1:n, word3])
  count <- nrow(pwords)
  bwords <- biGrams(w2, n)[1:(n - count)]
  return(c(pwords[, word3], bwords))
}



getNextWords <- function(str, n=5){

  str<-gsub(pattern = '[^a-zA-Z\\s]+',
            x = str,
            replacement = "",
            ignore.case = TRUE,
            perl = TRUE)
  
  tokens <- tokens(x = char_tolower(str),
                   what="fastestword",
                   remove_punct=TRUE,remove_numbers=TRUE,
                   remove_symbols = TRUE,remove_hyphens=TRUE,
                   remove_separators = TRUE,
                   remove_url = TRUE)
 
  
  tokens <- rev(rev(tokens[[1]])[1:2])
  
  words <- triGrams(tokens[1], tokens[2], n)
  chain_1 <- paste(tokens[1], tokens[2], words[1], sep = " ")
  
  print(words)
}


getNextWords("Shall we go to")

txtIn<-"The guy in front of me just bought a pound of bacon, a bouquet, and a case of"
getNextWords (txtIn)

#[1] "the"       "a"         "an"        "beer"      "emergency"

txtIn<-"You're the reason why I smile everyday. Can you follow me please? It would mean the"
getNextWords (txtIn)
#[1] "world"      "difference" "same"       "whole"      "most"  

txtIn<-"Hey sunshine, can you follow me and make me thee"
getNextWords (txtIn)
#[1] "and"  "to"   "i"    "best" "for" 

txtIn<-"Very early observations on the Bills game: Offense still struggling but the"
getNextWords (txtIn)

txtIn<-"Go on a romantic date at the"
getNextWords (txtIn)
#[1] "end"    "same"   "time"   "moment" "top"  

txtIn<-"Well I'm pretty sure my granny has some old bagpipes in her garage I'll dust them off and be on my"
getNextWords (txtIn)
#[1] "way"   "own"   "mind"  "phone" "blog" 

txtIn<-"Ohhhhh #PointBreak is on tomorrow. Love that film and haven't seen it in quite some"
getNextWords (txtIn)
#[1] "time"   "of"     "people" "time"   "more"  

txtIn<-"After the ice bucket challenge Louis will push his long wet hair out of his eyes with his little"
getNextWords (txtIn)
#[1] "brother" "sister"  "girl"    "head"    "body"   

txtIn<-"Be grateful for the good times and keep the faith during the"
getNextWords (txtIn)
#[1] "day"    "first"  "week"   "summer" "last" 

txtIn<-"If this isn't the cutest thing you've ever seen, then you must be"
getNextWords (txtIn)

#[1] "a"    "the"  "in"   "done" "able"

txtIn<-"When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd"
getNextWords (txtIn)
#[1] "be"     "be"     "and"    "like"   "rather"

txtIn<-"Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
getNextWords (txtIn)
#[1] "new"    "own"    "life"   "work"   "future"

txtIn<-"I'd give anything to see arctic monkeys this"
getNextWords (txtIn)
#[1] "is"      "year"    "week"    "morning" "weekend"

txtIn<-"Talking to your mom has the same effect as a hug and helps reduce your"
getNextWords (txtIn)
#[1] "risk"     "stress"   "exposure" "costs"    "monthly" 

txtIn<-"When you were in Holland you were like 1 inch away from me but you hadn't time to take a"
getNextWords (txtIn)
#[1] "look"    "picture" "break"   "nap"     "few"  

txtIn<-"I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"
getNextWords (txtIn)
#[1] "case"    "issue"   "matter"  "dispute" "bill"  

txtIn<-"I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each"
getNextWords (txtIn)
#[1] "of"        "other"     "direction" "case"      "category"

txtIn<-"Every inch of you is perfect from the bottom to the"
getNextWords (txtIn)
#[1] "next"   "point"  "public" "new"    "top"   

txtIn<-"I’m thankful my childhood was filled with imagination and bruises from playing"
getNextWords (txtIn)
#[1] "in"         "the"        "with"       "at"         "basketball"

txtIn<-"I like how the same people are in almost all of Adam Sandler's"

getNextWords (txtIn)

#rm(uniGramDT)
#rm(biGramDT)
#rm(triGramDT)
gcDet<-calcGc()
totaltimeTaken <- captureTimeTaken(appStartTime, "Total N-Gram model creation   ")

