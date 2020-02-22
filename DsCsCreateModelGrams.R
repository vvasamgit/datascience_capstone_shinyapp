
source("DsCsCommon.R")


startTime <- captureStartTime()
gcDet<-calcGc()

#allTknFile<-list.files(ngramDirHome,pattern=alltknFilePattern)

#allTkns<-readRDS(paste0(ngramDirHome,.Platform$file.sep,allTknFile[1]))

#dfmAll<-dfm(allTkns,tolower = TRUE, remove=stopwords('en'))

#nGram<-1

#saveRDS(dfmAll,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,dfmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

#Text frequency sorts the words and gives rank but not needed for this excercise ..
#ngramFeatAll<-textstat_frequency(dfmAll)

#allNgramSums<-colSums(dfmAll)


nGram<-1

ngramFilePattern<-paste0(nGramFilePrefix,nGram, "_(.)*.rds")

ngramFile<-list.files(ngramDirHome,pattern=ngramFilePattern)

ngrams<-readRDS(paste0(ngramDirHome,.Platform$file.sep,ngramFile[1]))

#dfmNgram<-dfm(ngrams,tolower = TRUE, remove=stopwords('en'))

dfmNgram<-dfm(ngrams)

dfmNgram<-dfm_trim(dfmNgram, 3)

saveRDS(dfmNgram,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,dfmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

ngramSums<-colSums(dfmNgram)


uniGramDT <- data.table(word1 = names(ngramSums), count = ngramSums)

uniGramDT<-uniGramDT[order(-count)]

saveRDS(uniGramDT,paste0(dataDirHome,.Platform$file.sep,nwmDir,.Platform$file.sep,nwmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

head(uniGramDT,5)

tail(uniGramDT,5)

rm(ngramSums)
rm(dfmNgram)
rm(ngrams)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " gram next word model creation "))
gcDet<-calcGc()


nGram<-2

ngramFilePattern<-paste0(nGramFilePrefix,nGram, "_(.)*.rds")

ngramFile<-list.files(ngramDirHome,pattern=ngramFilePattern)

ngrams<-readRDS(paste0(ngramDirHome,.Platform$file.sep,ngramFile[1]))

#dfmNgram<-dfm(ngrams,tolower = TRUE, remove=stopwords('en'))

dfmNgram<-dfm(ngrams)

dfmNgram<-dfm_trim(dfmNgram, 3)

saveRDS(dfmNgram,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,dfmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

ngramSums<-colSums(dfmNgram)

biGramDT <- data.table(word1 = sapply(strsplit(names(ngramSums), "_", fixed = TRUE), '[[', 1),word2= sapply(strsplit(names(ngramSums), "_", fixed = TRUE), '[[', 2), count = ngramSums)

biGramDT<-biGramDT[order(-count)]

saveRDS(biGramDT,paste0(dataDirHome,.Platform$file.sep,nwmDir,.Platform$file.sep,nwmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

head(biGramDT,5)

rm(ngramSums)
rm(dfmNgram)
rm(ngrams)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " gram next word model creation "))
gcDet<-calcGc()

nGram<-3

ngramFilePattern<-paste0(nGramFilePrefix,nGram, "_(.)*.rds")

ngramFile<-list.files(ngramDirHome,pattern=ngramFilePattern)

ngrams<-readRDS(paste0(ngramDirHome,.Platform$file.sep,ngramFile[1]))

#dfmNgram<-dfm(ngrams,tolower = TRUE, remove=stopwords('en'))

dfmNgram<-dfm(ngrams)

dfmNgram<-dfm_trim(dfmNgram, 3)

saveRDS(dfmNgram,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,dfmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

ngramSums<-colSums(dfmNgram)

triGramDT <- data.table(word1=sapply(strsplit(names(ngramSums), "_", fixed = TRUE), '[[', 1),
                        word2=sapply(strsplit(names(ngramSums), "_", fixed = TRUE), '[[', 2), 
                        word3= sapply(strsplit(names(ngramSums), "_", fixed = TRUE), '[[', 3),
                        count = ngramSums)

triGramDT<-triGramDT[order(-count)]

#nrow(triGramDT)


saveRDS(triGramDT,paste0(dataDirHome,.Platform$file.sep,nwmDir,.Platform$file.sep,nwmFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

head(triGramDT,5)

rm(ngramSums)
rm(dfmNgram)
rm(ngrams)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " gram next word model creation "))
gcDet<-calcGc()

rm(uniGramDT)
rm(biGramDT)
rm(triGramDT)
gcDet<-calcGc()
totaltimeTaken <- captureTimeTaken(appStartTime, "Total N-Gram model creation   ")

