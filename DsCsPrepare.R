
#creates tokens for each document in corpus 

source("DsCsCommon.R")


startTime <- captureStartTime()
gcDet<-calcGc()




fileInfo<-gatherFileInfo(dataDir,"*.txt$")
fileInfo<-gatherFileCounts(fileInfo)


corpFn<-str_split(fileInfo$fileName,"\\.")

corpDocName<-sapply(corpFn, "[[",1)

fileCount<-nrow(fileInfo)

corpusText<-character(fileCount)

str(corpusText)


#Read file contents and create corpus and save. Coprus with all file contents or 
#seperate for each file 

samplePercent<-100
#numSplits<-3

#compute no of lines based on sample percent 

sNumOflines<-sapply(1:nrow(fileInfo),function(fi){
  floor(as.integer(fileInfo[fi]$line_count)*samplePercent/100)
})


#fileText<-lapply(sNumOflines, function(i){character(i)})


for(fi in 1:fileCount){
  
  fileAbsPath<-fileInfo[fi]$absPath
  sLines<-sNumOflines[fi]
  sFileText<-read_lines(fileAbsPath,n_max=sLines)
  clnText<-sapply(sFileText, function(dText){
    return (gsub(pattern = '[^a-zA-Z\\s]+',
                 x = dText,
                 replacement = " ",
                 ignore.case = TRUE,
                 perl = TRUE)
    )
  }
  )
  
  rm(sFileText)
  
  sFileDoc<-paste(clnText,collapse="")
  
  rm(clnText)
  sCrop<-corpus(sFileDoc)
  rm(sFileDoc)
  saveRDS(sCrop,paste0(dataDirHome,.Platform$file.sep,corpdir,.Platform$file.sep,corpFilePefix, corpDocName[fi],".rds") )
  
  sTokens <- tokens(sCrop,what="fastestword",
                         remove_punct=TRUE,remove_numbers=TRUE,
                         remove_symbols = TRUE,remove_hyphens=TRUE,
                         remove_separators = TRUE,
                         remove_url = TRUE)
  
  saveRDS(sTokens,paste0(dataDirHome,.Platform$file.sep,tokenDir,.Platform$file.sep,tokenFilePrefix, corpDocName[fi],".rds") )
  rm(sTokens)
  gcDet<-calcGc()
  rm(sCrop)
  gcDet<-calcGc()
} # end of for for(fi in 1:fileCount) 

timeTaken <- captureTimeTaken(startTime, "Corpus creation and save ")
gcDet<-calcGc()

