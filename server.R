
library(pageviews)
library(dplyr)
library(plotly)
library(shiny)
library(RcppRoll)
gc()


#######################################
###  Server file for the Shiny app  ###
#######################################

## can be set to other languages as well
Sys.setlocale(locale =  "persian")

shinyServer(function(input, output) {
  
    df <- reactive({
    df = data.frame(matrix(vector(), 0, 8,
                           dimnames=list(c(), c("project" ,"language" ,"article", "access",
                                                "granularity", "date", "rank", "views"))))
    date1 <- input$dateRange[1]
    date2 <- input$dateRange[2]
    for (dt in date1:date2){
      topArts <- top_articles(project = "fa.wikipedia",
                              start = as.Date(dt, origin = '1970-01-01')
      )
      df <- rbind(df,topArts[,])
    }
    df
  })
  
  
  df2 <- reactive({
    df <- df()
    df2 <- df %>% group_by(article) %>%
      summarise(days = n(), view = sum(views)) %>%
      dplyr::filter(!grepl(  "جستجو" , x = .$article )) %>%
      dplyr::filter(!grepl(  "ویژه" , x = .$article )) %>%
      dplyr::filter(!grepl(  "صفحه" , x = .$article )) %>%
      dplyr::filter(!grepl(  "Special" , x = .$article )) %>%
      dplyr::filter(!grepl(  "ورود_به_سامانه" , x = .$article )) %>%
      dplyr::filter(!grepl(  "Search" , x = .$article )) %>%
      arrange(desc(view)) %>%
      mutate(rank =  1:nrow(.)) %>%
      mutate(perDay = view/days) %>%
      arrange(desc(perDay)) %>%
      mutate(rankPerDay =  1:nrow(.))  %>%
      dplyr::filter(rankPerDay < input$rank_day | rank < input$rank)   %>% 
       arrange_(input$rankOption)
  })
  

   arts <- reactive({
     k <- input$k
     df2 <- df2()
     date1 <- input$dateRange[1]
     date2 <- input$dateRange[2]
     arts <- article_pageviews(project = "fa.wikipedia", article =  head(df2$article,k)
                                , start = date1, end = date2
                                , user_type = c("user"), platform = c("all"))   %>% 
       group_by(article)   %>% 
       mutate(avg3 = roll_meanr(x = views, n=3, align = "right", fill = c(NA,NA,NA))) %>% as.data.frame()
     ### use a moving average to fill in the blanks
    })
  
  

   output$articlePlot <- renderPlotly({
     arts <- arts()
     plot_ly(x = ~ date, y = ~ avg3,
             mode = 'lines',
             color= ~factor(article),
             data= arts)
   })
   
  output$dataTable <- renderDataTable(df2())
 
  

})


