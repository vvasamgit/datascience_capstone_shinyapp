#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Data Science Capstone Next Word Prediction Application."),
  
  mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Next Word Prediction", 
                           br(),
                           br(),
                         
                           fluidRow( div(style="vertical-align:bottom",
                                         column(10, textInput("textin", "Type Words", "Hello",width="100%")),
                                         column(1,offest=1, style = "margin-top: 25px;", div(style = "text-align:center;" , actionButton('insertBtn', 'Show Next Words')))
                                        #, column(1,offest=1,style = "margin-top: 25px;", div(style = "text-align:center;" ,actionButton('removeBtn', 'Clear')))
                             )
                           ),
                           
                           tags$div(id = 'placeholder',style = "margin-right: 1px;") 
                           )
                  ,
                  tabPanel("Usage Guide", includeCSS("Mileage.html"))
      )
    )
))
