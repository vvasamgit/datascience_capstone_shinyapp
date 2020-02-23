
source("DsCsCommon.R")


fileInfo<-gatherFileInfo(dataDir,"*.txt$")

fileInfo<-gatherFileCounts(fileInfo)


fileCounts<-fileInfo[,.(fileName,size,line_count,word_count,char_count)]

fileCountsMelt<-melt(fileCounts, id.vars=c("fileName"), measure.vars = c("line_count","word_count"))


fileCountsMelt<-fileCountsMelt[,value_millions:=as.integer(value)/1000000]



filePlot<-ggplot(fileCountsMelt, aes(x = fileName, y = value_millions, fill = variable))+
  geom_col(position = "dodge")+
  coord_cartesian( ylim=c(1, 50))+
  xlab("SwiftKey Corpus English Files")+
  ylab("Value in millions")

#ggplotly(filePlot)

readDFMFile<-function(pNgram){
  pFilePattern<-paste0(dfmFilePrefix,pNgram, "_(.)*.rds")
  
  pFile<-list.files(ngramDirHome,pattern=pFilePattern)
  
  pFileDtaa<-readRDS(paste0(ngramDirHome,.Platform$file.sep,pFile[1]))
  
  return(pFileDtaa)
}



library(gridExtra)

docDfmrn1<-readDFMFile("1")

nGramVarName<-"Unigram"

uniTop<-createNgramTopFeatBarPlot(docDfmrn1, 20,nGramVarName)

docDfmrn2<-readDFMFile("2")

nGramVarName<-"bigram"

biTop<-createNgramTopFeatBarPlot(docDfmrn2, 20,nGramVarName)


dscea<-grid.arrange(filePlot,uniTop,biTop)

ggsave(file="dscea.jpeg", dscea)


if (!require("jpeg")) {
  install.packages("jpeg")
  library(jpeg)
}




img1 <- readJPEG("dscea.jpeg",native = TRUE)


if(exists("rasterImage")){
  plot(1:2, type='n')
  rasterImage(img1,1,1,2,2)
}


