library(dplyr)
library(ggplot2)
library(shiny)
library(shinydashboard)
library(ggthemes)

setwd("//scicomp/home-pure/flb8/git_repos/code_examples/RShiny/RShiny_examples")

cat1 <- as.character(c(1:10))
cat2 <-  c("a", "b", "a", "a", "a", "b", "b", "a", "a", "b")
cat3 <- c(1,3,6,9,12,15,18,21,24,27)
cat4 <- c("one", "one", "one", "two", "two", "four", "three", "five", "three", "four")

df <- data.frame(cat1, cat2, cat3, cat4)

#--------------------------------------------
ui <- 
  fluidPage(
    
    theme = bs_theme(version = 4, bootswatch = "lumen"),
    
    fluidRow(
      column(9, 
             offset = 0, 
             style = "font-size: 40px;font-face: bold; font-family: Sabon Next LT; padding: 0px 0px 0px 20px; margin:0px;",
             span("Example", style =  "float:left; font-face: bold; color: #112B51")
      )
    ),
    
    sidebarLayout(
      position = "left",
      
      sidebarPanel(
        width = 3, offset = 0,
        
        selectInput("set",
                    label = "Set:",
                    choices = c("All", unique(df$cat2))
        ),
        
        sliderInput(inputId = "age", 
                    label = "Choose Age Range:", 
                    min = min(df$cat3), 
                    max = 30,
                    value=c(1, 30),
                    step = 3)
      ),
      
      mainPanel(
        width = 9, offset=0,
        tabsetPanel(
          tabPanel('Dashboard',
                   br(),
                   
                   dashboardPage(
                     dashboardHeader(disable = TRUE),
                     dashboardSidebar(disable = TRUE),
                     dashboardBody(
                       box(
                         title = "Group distribution",
                         width = 6,
                         background = "light-blue",
                         solidHeader = TRUE,
                         plotOutput("group_bar", height = 300)
                       )
                     )
                   ),
                   downloadButton("data", "Download Data"),
                   downloadButton("report", "Download Report")
          )
        )
      )
    )
  )


#------------------------------------------------
server <- function(input, output, session) {
  
  rval_filters <- reactive({
    req(input$set)
    req(input$age)

    data <- df

    #filter data set
    if (input$set != "All"){
      data <- data %>%
        filter(cat2 %in% input$set)
    } else {
      data
    }

    #filter based on age range
    data <- data %>%
      filter(cat3 >= input$age[1] & cat3 <= input$age[2])
    data

  })


  plot_bar <- reactive({
    group <- rval_filters() %>%
      group_by(cat4) %>%
      summarise(n = n())
    
    plot_bar <- ggplot(group, aes(x = n, y = reorder(cat4, n))) +
      geom_bar(stat = "identity", fill = "#4C7A99") +
      theme_minimal() +
      labs(x = "Count")
    
    plot_bar
  })
  
  # plot by group
  output$group_bar <- renderPlot({
    plot_bar()
  })
  


  output$report <- downloadHandler(
    filename = "report.html",
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        n = rval_filters(),
        plot = plot_bar()
      )
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
  output$data <- downloadHandler(
    filename = function(){
      paste0("report", ".csv")
    },
    content = function(file){
      write.csv(rval_filters(), file)
    }
  )
  
  }

# Run app ----
shinyApp(ui, server)