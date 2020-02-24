
library(shiny)

source("DsCsCommon.R")



gcDet<-calcGc()

readNextWordModelFinalFile<-function(pNgram){
  
  nwmFinalFilePattern<-paste0(nwmFinalFilePrefix,pNgram, "_(.)*.rds")
  
  nwmFinalFile<-list.files(nwmDirHome,pattern=nwmFinalFilePattern)
  
  nwmFinal<-readRDS(paste0(nwmDirHome,.Platform$file.sep,nwmFinalFile[1]))
  
  return (nwmFinal)
}


uniGramDT<-readNextWordModelFinalFile("1")

biGramDT<-readNextWordModelFinalFile("2")

triGramDT<-readNextWordModelFinalFile("3")

#setnames(triGramDT,old="prevcount", new="prevGramPrevWcount")

head(triGramDT,5)

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
  
  #print(words)
  return (words )
}





addButton<-function(selectorid,nextwords, uids){
  # print("Addd buttons ..")
  for( i in 1:length(nextwords)){
    btnId<-paste0("button",i)
    btnName<-nextwords[i]
    insertUI(
      selector = selectorid,
      where = "beforeEnd",
      
      ui =actionButton(btnId, label=btnName )
      
    )
    uids <- c(btnId, uids)
  }
  # print(uids)
  return (uids)
}

removeButtons<-function(uids){
  # print(paste("Remove buttons ..",length(uids)))
  totalBtns<-length(uids)
  for( i in 1:totalBtns){
    btnId<- paste0("#",uids[i])
    #print(btnId)
    removeUI(
      selector =btnId
    )
    
  }
  uids <- c()
  return (uids)
}


# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  
  #Executed after event
  #observe({ 
  #   print("in observe") 
  #}
  # )

  observeEvent(input$textin,{
   output$eventOut <- renderText({
    paste("Last Resonse :", input$textin , "time:",Sys.time() )
   })
  }
  )
  
  output$value <- renderText({ input$textin })
 

  ## keep track of elements inserted and not yet removed
  inserted <- c()
  
  #nextW<-c("one", "two","threw","four", "five")
  
  nextW<-c()

  #Show Next Words Button Event Handler 
  
  observeEvent(input$insertBtn, {
    
    startTime <- captureStartTime()
    
    removeButtons(inserted)
  
    btn <- input$insertBtn
    id <- paste0('txt', btn)
    selector1<-'#placeholder'
    
    nextW<<-getNextWords(input$textin)
    
    inserted<<-addButton(selector1,nextW,inserted)
 
    print(inserted ) 
    gcDet<-calcGc()
    timeTaken <- captureTimeTaken(startTime, paste0("next word "))
  }
  )
  
  observeEvent(input$removeBtn, {
    
    inserted<<- removeButtons(inserted)  
  }
  )
  
  observeEvent(input$button1, {
    print( paste(" clicked :",nextW[1]))
    updateTextInput(session,"textin",value=paste(input$textin,nextW[1]) )
    removeButtons(inserted)
  })
  
  observeEvent(input$button2, {
    print( paste(" clicked :",nextW[2]))
    updateTextInput(session,"textin",value=paste(input$textin,nextW[2]) )
    removeButtons(inserted)
  })
  
  observeEvent(input$button3, {
    print( paste(" clicked :",nextW[3]))
    updateTextInput(session,"textin",value=paste(input$textin,nextW[3]) )
    removeButtons(inserted)
  })
  
  observeEvent(input$button4, {
    print( paste(" clicked :",nextW[4]))
    updateTextInput(session,"textin",value=paste(input$textin,nextW[4]) )
    removeButtons(inserted)
  })
  
  observeEvent(input$button5, {
    print( paste(" clicked :",nextW[5]))
    updateTextInput(session,"textin",value=paste(input$textin,nextW[5]) )
    removeButtons(inserted)
  })
  
  
  
  # end 
  
  
}
)
