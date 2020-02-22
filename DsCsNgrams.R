
#Read token files and create 1 to 5 gram files ..

source("DsCsCommon.R")


startTime <- captureStartTime()
gcDet<-calcGc()



#corpFiles<-list.files(corpDirHome,pattern=corpFilePattern)


tknpFiles<-list.files(tknDirHome,pattern=tknFilePattern)


tkns<-lapply(tknpFiles, function(tknFile){
 tkn<-readRDS(paste0(tknDirHome,.Platform$file.sep,tknFile))
 names(tkn)<-tknFile
 return (tkn)
})


allTkns<-tkns[[1]]
for (i in 2:length(tkns)){
  allTkns<-allTkns+ tkns[[i]]
}



#saveRDS(allTkns,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,allTokenFilePrefix,capstoneFileSuffix, ".rds") )

nGram=1

saveRDS(allTkns,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,nGramFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )

rm(tkns)
timeTaken <- captureTimeTaken(startTime, "Tokens load ")
gcDet<-calcGc()

startTime <- captureStartTime

#ngramToken24 <- tokens_ngrams(allTkns,n=2:5)

#[1] "Tokens load time captured as: 1.23803831736247secs"
#1] "Memory Used :480.7, Max memory used:1878.5"

#tokens and uni gram is same ...
#nGram=1
#nGram1<-createNgram(allTkns,1)
#str(nGram1)

startTime <- captureStartTime()
nGram=2
nGramToken<-createNgram(allTkns,nGram)
saveRDS(nGramToken,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,nGramFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )
rm(nGramToken)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " Tokens creation "))
gcDet<-calcGc()

#[1] "2 Tokens creation time captured as: 2.87596385081609secs"
#[1] "Memory Used :480.7, Max memory used:2851.1"

startTime <- captureStartTime()
nGram=3
nGramToken<-createNgram(allTkns,nGram)
saveRDS(nGramToken,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,nGramFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )
rm(nGramToken)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " Tokens creation "))
gcDet<-calcGc()

#[1] "3 Tokens creation time captured as: 9.6752600034078secs"
#[1] "Memory Used :608.6, Max memory used:5954.3"

startTime <- captureStartTime()
nGram=4
nGramToken<-createNgram(allTkns,nGram)
saveRDS(nGramToken,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,nGramFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )
rm(nGramToken)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " Tokens creation "))
gcDet<-calcGc()

#[1] "4 Tokens creation time captured as: 29.1405948996544secs"
#[1] "Memory Used :864.6, Max memory used:10107.6"

startTime <- captureStartTime()
nGram=5
nGramToken<-createNgram(allTkns,nGram)
saveRDS(nGramToken,paste0(dataDirHome,.Platform$file.sep,nGramsDir,.Platform$file.sep,nGramFilePrefix,nGram,"_", capstoneFileSuffix, ".rds") )
rm(nGramToken)
timeTaken <- captureTimeTaken(startTime, paste0(nGram, " Tokens creation "))
rm(allTkns)
gcDet<-calcGc()

#[1] "5 Tokens creation time captured as: 36.276805015405secs"
# gcDet<-calcGc()
#[1] "Memory Used :864.6, Max memory used:11472.4"

totaltimeTaken <- captureTimeTaken(appStartTime, "Total N-Gram creation   ")

#[1] "Total N-Gram creation   time captured as: 1 hr 30 min  (36.9706113855044secs-wrong bug in captureTimeTaken )"

#OS Name:                   Microsoft Windows 10 Enterprise
#OS Version:                10.0.17134 N/A Build 17134
#System Manufacturer:       Dell Inc.
#System Model:              Latitude E6440
#System Type:               x64-based PC
#Processor(s):              1 Processor(s) Installed.
#[01]: Intel64 Family 6 Model 60 Stepping 3 GenuineIntel ~1300 Mhz
#BIOS Version:              Dell Inc. A14, 12/1/2015
#Total Physical Memory:     16,289 MB
#Available Physical Memory: 2,439 MB
#Virtual Memory: Max Size:  38,512 MB
#Virtual Memory: Available: 17,101 MB
#Virtual Memory: In Use:    21,411 MB