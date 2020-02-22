
source("DsCsCommon.R")



#Start Execution of application

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

fileInfo

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
