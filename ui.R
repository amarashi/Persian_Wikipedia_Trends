
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(plotly)
library(shiny)

shinyUI(fluidPage(

  titlePanel("Trends in Persian Wikipedia"),

  sidebarLayout(
    sidebarPanel(
      dateRangeInput('dateRange',
                     label = 'Date range:',
                     start = Sys.Date() - 365, end = Sys.Date() - 345,
                     min = Sys.Date() - 1000, max = Sys.Date() - 10,
                     separator = " - ", format = "dd/mm/yy",
                     startview = 'year', language = 'en', weekstart = 1
      ),
      selectInput("rankOption",label = "How to rank",choices = c("Overall top pages" = "rank",
                                                                 "Rare events"= "rankPerDay")),
      numericInput("rank",label = "max total rank:",value = 700,min = 0,max = 1000),
      numericInput("rank_day",label = "max daily rank:",value = 700,min = 0,max = 1000),
      numericInput("k",label = "number of topics:",value = 20,min = 1,max = 100),
      submitButton("Submit")
      
      
    ),

    mainPanel(
      plotlyOutput('articlePlot'),
      dataTableOutput("dataTable")
      # ,
      # textOutput("dateRangeText")
    )
  )
))
