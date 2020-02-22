 

appStartTime <- Sys.time()

#Load libraries


if (!require("devtools")) {
  install.packages("devtools")
  library(devtools)
}

if (!require("RColorBrewer")) {
  install.packages("RColorBrewer")
  library(RColorBrewer)
}

if (!require("quanteda")) {
  install.packages("quanteda")
  library(quanteda)
}

if (!require("data.table")) {
  install.packages("data.table")
  library(data.table)
}

if (!require("readr")) {
 install.packages("readr")
library(readr)
}

if (!require("stringr")) {
 install.packages("stringr")
  library(readr)
}

if (!require("readtext")) {
  install.packages("readtext")
  library(readr)
}


if (!require("ggplot2")) {
  install.packages("ggplot2")
  library(readr)
}

if (!require("plotly")) {
  install.packages("plotly")
  library(plotly)
}

#devtools::install_github("quanteda/quanteda.corpora")

#devtools::install_github("quanteda/spacyr", build_vignettes = FALSE)

#devtools::install_github("kbenoit/quanteda.dictionaries")




#Define Global variables

fileSep<-.Platform$file.sep
fileInfo<-c()

gcDet<-data.table(memUsedMb=numeric(), maxMemUsedMb=numeric())
gcDet<-rbind(gcDet, list(0,0))
invisible(gc(reset=TRUE))
gcPrev<-invisible(gc())
gcNow<-invisible(gc())

#capture time function

captureStartTime<-function(){
  return(Sys.time())
}

#capture time taken function

captureTimeTaken<-function(pStartTime, msg=""){
  
  endTime <- Sys.time()
  
  timeTaken <- endTime - startTime

  print(paste0(msg, "time captured as: ",timeTaken,"secs"))
  
  return( timeTaken )
}  


# Captire Memory Usage function 
calcGc<-function(){
  gcPrev<-gcNow
  gcNow<-invisible(gc())
  gcDet<-data.table(memUsedMb=numeric(), maxMemUsedMb=numeric())
  gcDet<-rbind(gcDet, list(0,0))
  usedMb<-sum(gcNow[,2]-gcPrev[,2])
  maxUsedMb<-sum(gcNow[,6]-gcPrev[,6])
  gcDetRow<- c(usedMb,maxUsedMb)
  gcDet[1,]<-list(usedMb,maxUsedMb)
  print(paste0("Memory Used :",gcDet$memUsedMb, ", Max memory used:",gcDet$maxMemUsedMb))
  return (gcDet)
}


#Gather file details such as name and sizes

gatherFileInfo<-function(pDataHomeDir,filePattern){
  
  oFileNames<-list.files(pDataHomeDir,pattern=filePattern)
  nFileNames<-sapply(oFileNames, function(x){ 
    gsub("(\\.)([a-zA-Z]*)(\\.)([a-zA-Z]*)$", "_\\2\\3\\4",x)
  }
  )
  
  curdir<-getwd()
  setwd(pDataHomeDir)
  
  file.rename(oFileNames,nFileNames)
  
  setwd(curdir)
  
  fileSep<-.Platform$file.sep
  
  absPath<-sapply(nFileNames, function(x){
    paste(pDataHomeDir,fileSep,x,sep="")
  })
  
  names(absPath)<-c()
  
  fileInfo<-file.info(absPath)
  
  rownames(fileInfo)<-c()
  
  fileName<-nFileNames
  
  names(fileName)<-c()
  
  names (absPath)<-c()
  
  fileInfo<-cbind(absPath, fileInfo,stringsAsFactors = FALSE )
  
  fileInfo<-cbind(fileName, fileInfo,stringsAsFactors = FALSE )
  
  return (setDT(fileInfo))
  
}


wcHome<-"C:/Instls/Rtools/bin" 
cmdWc<-paste0(wcHome, fileSep, "wc ")

#Run Operating System Command  function 
runCmd<- function(cmd, option, fileAbsPath){
  cmdRes<-system(paste(cmd,option,fileAbsPath,sep=" "),intern=TRUE) 
  cmdRes<-str_split(str_trim (cmdRes),"[[:space:]]+");
}

#Gather file counts function
gatherFileCounts<-function(pfileInfo){
  pfileInfo<-pfileInfo[,line_count:=.()]
  pfileInfo<-pfileInfo[,word_count:=.()]
  pfileInfo<-pfileInfo[,char_count:=.()]
  
  pfileCount<-nrow(pfileInfo)
  
  
  for (i in 1:pfileCount){
    #print(pfileInfo[i]$absPath)
    wcRes<-runCmd(cmdWc,"-lwm",pfileInfo[i]$absPath)
    pfileInfo[i]$line_count=wcRes[[1]][1]
    pfileInfo[i]$word_count=wcRes[[1]][2]
    pfileInfo[i]$char_count=wcRes[[1]][3]
  }
  return(pfileInfo)
}


createSampleDataFiles<-function (pSamplePercent, pFileInfo, pDataDirHome){
  
  #create sample percent directory under data diretcory
  
  subDir<-paste("sample",pSamplePercent, sep="_")
  
  
  dirExists<-ifelse(dir.exists(file.path(pDataDirHome, subDir)), TRUE, dir.create(file.path(pDataDirHome, subDir)))
  
  fileCount<-nrow(pFileInfo)
  
  for(fi in 1:pFileInfo){
    # fi<-1
    
    #reading seperate lines by skipping causing problem so read all lines. The object can be removed after 
    # saving train and test data sets
    
    pFileAbsPath<-pFileInfo[fi]$absPath
    
    fAllData<-read_lines(pFileAbsPath)
    
    trnSampleFile<-paste("train","1",fileInfo[fi]$fileName,sep="_")
    trnSampleFile
    trnSampleFileAbs<-paste0(file.path(dataDirHome, subDir),fileSep,trnSampleFile )
    
    trnSampleFileAbs
    
    tstSampleFile<-paste("test","1",fileInfo[fi]$fileName,sep="_")
    tstSampleFile
    tstSampleFileAbs<-paste0(file.path(dataDirHome, subDir),fileSep,tstSampleFile )
    tstSampleFileAbs
    
    # Based on the total number of lines in file create sample line numbers for training and test sets out of 1 percent
    
    lineCount<-as.integer(fileInfo[fi]$line_count)
    
    pLineCount<-floor(lineCount*samplePercent/100)
    
    set.seed(20)
    
    sLineNos<-sample(lineCount, size=pLineCount, replace=FALSE)
    
    sTrnLineNos<-sample(sLineNos, size=0.8*length(sLineNos),replace=FALSE)
    
    plineCount<- length(sTrnLineNos)
    
    ftrnData<-character(plineCount)
    
    for (i in 1:plineCount){
      ftrnData[i]<- fAllData[i]
    }
    
    write_lines(ftrnData,trnSampleFileAbs)
    
    sTestLineNos<-setdiff(sLineNos,sTrnLineNos)
    
    ptstlineCount<- length(sTestLineNos)
    
    
    ftstData<-character(ptstlineCount)
    
    for (i in 1:ptstlineCount){
      ftstData[i]<- fAllData[i]
    }
    
    write_lines(ftstData,tstSampleFileAbs)
    rm(fAllData)
  }

  sampleDir<-paste(pDataDirHome,fileSep,subDir,sep="")
  return (sampleDir )
}  #End Create Sample


createAndSaveSampleCoprus<-function (pSamplePercent,pNumberOfSplits, pFileInfo, pDataDirHome){
  
  #create sample percent directory under data diretcory
  
  subDir<-paste("sample",pSamplePercent, sep="_")
  
  
  dirExists<-ifelse(dir.exists(file.path(pDataDirHome, subDir)), TRUE, dir.create(file.path(pDataDirHome, subDir)))
  
  fileCount<-nrow(pFileInfo)
  
  #Read file contents and create corpus and save. Coprus with all file contents or 
  #seperate for each file 
  

  
  for(fi in 1:pFileInfo){
    # fi<-1
    
    #reading seperate lines by skipping causing problem so read all lines. The object can be removed after 
    # saving train and test data sets
    
    pFileAbsPath<-pFileInfo[fi]$absPath
    
    fAllData<-read_lines(pFileAbsPath)
    
    trnSampleFile<-paste("train","1",fileInfo[fi]$fileName,sep="_")
    trnSampleFile
    trnSampleFileAbs<-paste0(file.path(dataDirHome, subDir),fileSep,trnSampleFile )
    
    trnSampleFileAbs
    
    tstSampleFile<-paste("test","1",fileInfo[fi]$fileName,sep="_")
    tstSampleFile
    tstSampleFileAbs<-paste0(file.path(dataDirHome, subDir),fileSep,tstSampleFile )
    tstSampleFileAbs
    
    # Based on the total number of lines in file create sample line numbers for training and test sets out of 1 percent
    
    lineCount<-as.integer(fileInfo[fi]$line_count)
    
    pLineCount<-floor(lineCount*samplePercent/100)
    
    splitSize=pLineCount/pNumberOfSplits
    
    set.seed(20)
    
    sLineNos<-sample(lineCount, size=pLineCount, replace=FALSE)
    
    sTrnLineNos<-sample(sLineNos, size=0.8*length(sLineNos),replace=FALSE)
    
    plineCount<- length(sTrnLineNos)
    
    ftrnData<-character(plineCount)
    
    for (i in 1:plineCount){
      ftrnData[i]<- fAllData[i]
    }
    
    write_lines(ftrnData,trnSampleFileAbs)
    
    sTestLineNos<-setdiff(sLineNos,sTrnLineNos)
    
    ptstlineCount<- length(sTestLineNos)
    
    
    ftstData<-character(ptstlineCount)
    
    for (i in 1:ptstlineCount){
      ftstData[i]<- fAllData[i]
    }
    
    write_lines(ftstData,tstSampleFileAbs)
    rm(fAllData)
  }
  
  sampleDir<-paste(pDataDirHome,fileSep,subDir,sep="")
  return (sampleDir )
}  #End Create Sample




createNgramAndClean<-function(pCorpusTokens,nGramCnt) {
  
  ngramToken <- tokens_ngrams(pCorpusTokens,nGramCnt)
  
 # ngramTokenCln<-tokens(ngramToken,what="fasterword",remove_punct=TRUE,remove_numbers=TRUE,remove_symbols = TRUE,remove_hyphens=TRUE)
  
  ngramTokenCln<-tokens(ngramToken)
  
  #ngramTokenCln <- tokens_select(ngramTokenCln, pattern = stopwords('en'), selection = 'remove')
  
  return(ngramTokenCln)
}


createDfmStem<-function(pNgramTokenCln) {
  
  #docDfmTrn <- dfm(pNgramTokenCln,tolower = TRUE, stem=TRUE, remove=stopwords('en'))
  
  docDfmTrn <- dfm(pNgramTokenCln,tolower = TRUE, stem=TRUE)
  
  
}


createNgramTopFeatBarPlot<-function(pDocDfmTrn, pTopN,pVarName) {

  docDfmSortTrn1<-dfm_sort(pDocDfmTrn,margin = "both")
  
  topFeatures <- topfeatures(docDfmSortTrn1, n=pTopN)
  
  topFeaturesDT <- data.table(nGramWordCount=topFeatures)
  
  topFeaturesDT<-topFeaturesDT[,nGramWords:=.(names(topFeatures))]
  
  topFeaturesDT
 
  topFeaturesPlot <- ggplot(topFeaturesDT, aes(x=reorder(nGramWords, -nGramWordCount), y=nGramWordCount))
  topFeaturesPlot <- topFeaturesPlot + geom_bar(position = "identity", stat = "identity")
  topFeaturesPlot <- topFeaturesPlot + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + xlab(paste0("Top ",pVarName, " Words")) + ylab("Count")
  
  print(topFeaturesPlot)
  
  return(topFeaturesPlot)
}
  


createNgramAndCleanDfm<-function(pCorpusTokens,nGramCnt,pVarName) {
  
  docTokensTrn0 <- tokens_ngrams(pCorpusTokens,nGramCnt)
  
  docTokensTrn1<-tokens(docTokensTrn0,remove_punct=TRUE,remove_numbers=TRUE)
  
  docTokensTrn1<-tokens(docTokensTrn1,remove_symbols = TRUE,remove_hyphens=TRUE)
  
  docTokensTrn1 <- tokens_select(docTokensTrn1, pattern = stopwords('en'), selection = 'remove')
  
  docDfmTrn <- dfm(docTokensTrn1,tolower = TRUE, stem=TRUE, remove=stopwords('en'))
  
  docDfmSortTrn1<-dfm_sort(docDfmTrn,margin = "both")
  
  textplot_wordcloud (docDfmSortTrn1, max_words=100,color = brewer.pal(8,"Accent"))
  
  topFeatures <- topfeatures(docDfmSortTrn1, n=20)
  
  topFeaturesDf <- data.frame(topFeatures)
  
  topFeaturesDf["nGram"] <- rownames(topFeaturesDf)
  
  topFeaturesPlot <- ggplot(topFeaturesDf, aes(x=reorder(nGram, -topFeatures), y=topFeatures))
  topFeaturesPlot <- topFeaturesPlot + geom_bar(position = "identity", stat = "identity")
  topFeaturesPlot <- topFeaturesPlot + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + xlab(paste0("Top ",pVarName, " Word")) + ylab("Count")
  
  print(topFeaturesPlot)
  
  return(docDfmSortTrn1)
  
}




?tokens_ngrams


#Start Execution of application

#g1<-invisible(gc())

curdir<-getwd()

dataURL<-"https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"

dataDirHome<-"./data"

dataZipFilePath<- paste0(dataDirHome, "/tmp/Coursera-SwiftKey.zip")

dataZipExtractDir<-paste0(dataDirHome, "/orig")

#Download data zip file and extract

if(!file.exists(dataZipFilePath)){
 download.file(dataURL, dataZipFilePath)
 #Extract zip file 
 unzip(dataZipFilePath,exdir=dataZipExtractDir)
}

dataDir<-paste0(dataZipExtractDir,"/final/en_US")


fileInfo<-gatherFileInfo(dataDir,"*.txt$")

fileInfo<-gatherFileCounts(fileInfo)


fileCounts<-fileInfo[,.(fileName,size,line_count,word_count,char_count)]


#fileCountsMelt<-melt(fileCounts, id.vars=c("fileName"), measure.vars = c("line_count","word_count","char_count"))

fileCountsMelt<-melt(fileCounts, id.vars=c("fileName"), measure.vars = c("line_count","word_count"))


fileCountsMelt<-fileCountsMelt[,value_millions:=as.integer(value)/1000000]



filePlot<-ggplot(fileCountsMelt, aes(x = fileName, y = value_millions, fill = variable))+
  geom_col(position = "dodge")+
  coord_cartesian( ylim=c(1, 50))+
xlab("SwiftKey Corpus English Files")+
  ylab("Value in millions")

ggplotly(filePlot)

#ggplot(fileCountsMelt, aes(x = fileName, y = as.integer(value), fill = variable)) 
#+ geom_col(position = "dodge")
#+scale_y_log10()

#+coord_trans(y="log10")

#+scale_y_log10(limits = c(1,1e8))
               
#+coord_cartesian( ylim=c(1, 10000))

  
?scale_x_discrete

samplePercent<-1

startTime <- captureStartTime()

sampleDir<-createSampleDataFiles(samplePercent, fileInfo, dataDirHome)


captureTimeTaken(startTime, paste0(samplePercent," percent sample data files creation "))

startTime <- captureStartTime()

docDf <- readtext(paste(sampleDir,"/*.txt", sep=""),
                    docvarsfrom = "filenames",
                    docvarnames = c("dataset_category", "sample_percent","locale","country", "content_catgeory"),
                    dvsep = "_",
                    encoding = "UTF-8")



#Keep only alphabets

 
clnText<-sapply(docDf$text, function(dText){
  return (gsub(pattern = '[^a-zA-Z\\s]+',
               x = dText,
               replacement = " ",
               ignore.case = TRUE,
               perl = TRUE)
  )
}
)



#grep('[_]+',clnText[1])
#grep('[-]+',clnText[1])


# Set cleaned text to document text

docDf$text<-clnText

#Create corpus object

docCorpus <- corpus(docDf)

#Create trainig corpus object

docCorpTrn <- corpus_subset(docCorpus, dataset_category=="train")

#Create testing corpus object

docCorpTst <- corpus_subset(docCorpus, dataset_category=="test")


#docTokensTrn <- tokens(docCorpTrn,what="fasterword",remove_punct=TRUE,remove_numbers=TRUE,remove_symbols = TRUE,remove_hyphens=TRUE)

docTokensTrn <- tokens(docCorpTrn,what="fastestword",
                       remove_punct=TRUE,remove_numbers=TRUE,
                       remove_symbols = TRUE,remove_hyphens=TRUE,
                       remove_separators = TRUE,
                       remove_url = TRUE)


timeTaken <- captureTimeTaken(startTime, "Corpus (training and test) and tokens creation")

gcDet<-calcGc()

startTime <- captureStartTime()

nGramVarName<-"Unigram"

#docNgram1Dfm<-createNgramAndCleanDfm (docTokensTrn,1, nGramVarName)

docTokensTrnCln<-createNgramAndClean(docTokensTrn,1)
docDfmrn1<-createDfmStem(docTokensTrnCln)
textplot_wordcloud (docDfmrn1, max_words=100,color = brewer.pal(8,"Accent"))

timeTaken <- captureTimeTaken(startTime, "Unigram and word cloud creation")
gcDet<-calcGc()

startTime <- captureStartTime()

createNgramTopFeatBarPlot(docDfmrn1, 20,nGramVarName)

timeTaken <- captureTimeTaken(startTime, "Unigram plot creation")

gcDet<-calcGc()


#docNgram2Dfm<-createNgramAndCleanDfm (docTokensTrn,2, "Bigram")


startTime <- captureStartTime()

docTokensTrncln2<-createNgramAndClean(docTokensTrn,2)

docDfmrn2<-createDfmStem(docTokensTrncln2)

textplot_wordcloud (docDfmrn2, max_words=100,color = brewer.pal(8,"Accent"))


timeTaken <- captureTimeTaken(startTime, "bigram and word cloud creation")
gcDet<-calcGc()

startTime <- captureStartTime()

createNgramTopFeatBarPlot(docDfmrn2, 20, "Bigram")

#docNgram3Dfm<-createNgramAndCleanDfm (docTokensTrn,3, "trigram")

timeTaken <- captureTimeTaken(startTime, "bigram plot creation")

gcDet<-calcGc()

startTime <- captureStartTime()

docTokensTrncln3<-createNgramAndClean(docTokensTrn,3)

docDfmrn3<-createDfmStem(docTokensTrncln3)


textplot_wordcloud (docDfmrn3, max_words=100,color = brewer.pal(8,"Accent"))

timeTaken <- captureTimeTaken(startTime, "trigram and word cloud creation")
gcDet<-calcGc()

startTime <- captureStartTime()

createNgramTopFeatBarPlot(docDfmrn3, 20, "Trigram")

timeTaken <- captureTimeTaken(startTime, "trigram plot creation")

gcDet<-calcGc()


calcGc()


totaltimeTaken <- captureTimeTaken(appStartTime, "Total Sample Exploratory Analysis  ")

########
