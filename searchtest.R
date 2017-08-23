library(shiny)

ui <- fluidPage(
  actionButton("go", "Go"),
  textInput("n", "n", 50),
  textOutput("locationText")
)

server <- function(input, output) {
  
  location <- eventReactive(input$go, {
    input$n
  })
  
  output$locationText <- renderText({
    location()
  })
}

shinyApp(ui, server)

