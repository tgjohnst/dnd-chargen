#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

# Simple UI for character selection
ui <- fluidPage(
  theme = shinytheme("slate"),
   
   titlePanel("D&D character generator"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("randomness",
                     "Randomness:",
                     min = 0.1,
                     max = 2,
                     value = 1),
         sliderInput("n_char",
                     "Generation length",
                     min = 100,
                     max = 500,
                     value = 350),
         textInput("seed",
                  "Random Seed",
                  value="Qqwertyu"),
         actionButton('generate',"Generate")
      ),
      
      # Show the characters' names
      mainPanel(
         verbatimTextOutput("character")
      )
   )
)

# Define server logic required to generate characters. locations hardcoded for now
server <- function(input, output) {
  observeEvent(input$generate, {
    syscmd <- paste0(c(
      'cd /home/deeplearn/auto_rnngine && ',
      'PYTHONIOENCODING=UTF-8 python2 ',
      'tensorflow-char-rnn/sample.py ',
      '--init-dir ./models/dnd_characters_lstm_hs256_nl2_nu10_lr0.002/ ',
      '--temperature ', input$randomness, ' ',
      '--length ', input$n_char, ' ',
      '--start-text ', input$seed), collapse='')
    withProgress(message = 'Generating characters...', value=0.5, {
      gen_texts <- system(syscmd, intern=T)
      gen_texts <- gen_texts[-c(1,2,length(gen_texts))]
      output$character <- renderText({paste0(gen_texts, collapse='\n')})
    })
   },ignoreInit = TRUE, ignoreNULL = TRUE)
}

# Run the application 
shinyApp(ui = ui, server = server)

