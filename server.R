require(shiny)
require(leaflet)
require(spatial)
require(ggmap)

source("mapproto.R")

shinyServer(function(input, output, session) {
  
  #Initial text
  output$legendCluster <- renderText("Cluster of schools in area (click to expland)")
  output$legendlegendClusterPic <- renderUI(img(src="https://thumb.ibb.co/eQh92Q/Screen_Shot_2017_08_19_at_3_25_16_pm.png"))
  output$schoolName <- renderText("Click an icon to get information on that school")
  
  #Legend
  output$SafeSchools <- renderUI(
    tags$img(src= "LGBTSafe.png",
             width= "120px",
             style="object-fit:contain;max-height:280px;")
  )
  
  #Which schools to show
  primary3 <- reactive({
    primary3 <- data.frame()
    if(input$governmentEnable == TRUE)
    {primary3 <- rbind(primary3, primary2[primary2$Sector == "Government",])}
    if(input$catholicEnable == TRUE)
    {primary3 <- rbind(primary3, primary2[primary2$Sector == "Catholic",])}
    if(input$independentEnable == TRUE)
    {primary3 <- rbind(primary3, primary2[primary2$Sector == "Independent",])}
    return(primary3)
  })
  
  
  ########## Functions ############
  
  getIcons <- function(){
    B <- list()
    A <- data.frame()
    
    for(i in 1:nrow(primary3())){
      A <- primary3()[i,]
      if(A$LGBT){
        if(A$Sector == "Government"){
          B[i] <- "LGBTSafe.png"
        }
        else if(A$Sector == "Independent"){
          B[i] <- "icons8-School-48-Independent-LGBT.png"
        }
        else if(A$Sector == "Catholic"){
          B[i] <- "icons8-School-48-Catholic-LGBT.png"
        }
      }
      else{
        if(A$Sector == "Government"){
          B[i] <- "icons8-School-48.png"
        }
        else if(A$Sector == "Catholic"){
          B[i] <- "icons8-School-48-Catholic.png"
        }
        else if(A$Sector == "Independent"){
          B[i] <- "icons8-School-48-Independent.png"
        }
      }
    }
    return(B)
  }
    
  #School Info Box - get info if click on marker
  observe({
    click<-input$map_marker_click
    if(is.null(click)){
      click <- input$map_shape_click
    }
    if(is.null(click))
      return()
    clickedSchool <- primary2[primary2$Longitude == click$lng,]
    output$schoolName <- renderText(if(is.na(clickedSchool$School_Name)){
      "Sorry, we were unable to retrieve information on this school"
    }
    else{
      as.character(clickedSchool$School_Name[1])
    })
    output$schoolType <- renderText(paste("<b>School Type: <b>", as.character(clickedSchool$Sector[1])))
    output$schoolAddress <- renderText(paste("<b>Address: </b>", as.character(clickedSchool$Address1[1]),
                                          as.character(clickedSchool$Address2[1]),
                                          as.character(clickedSchool$Town),
                                          as.character(clickedSchool$State),
                                          as.character(clickedSchool$Postcode, sep = ', ')))
    output$schoolPhone <- renderText(paste("<b>Ph No: </b>", as.character(clickedSchool$Phone[1])))
    output$studentQty <- renderText(paste("<b>Students: </b>", as.integer(clickedSchool$Total[1])))
  })
    
  
 
  #
  #
  # Location search and validation
  #
  #

  postcodes <- c(read.csv("postcodes.csv"))
  postcodes <- postcodes$X3000
  A <- "Melbourne"
  y <- ""
  #Search for location on press go
  location <- eventReactive({
    input$keypress
    input$go
    },{
    A <- input$n
    if((tolower(A) %in% tolower(postcodes)) & (A != y)){
      x <- geocode(paste(input$n,", Vic, Australia"))
      y <- A
    }
    else{
      x <- "error"
    }
    return(x)
  }, ignoreNULL = FALSE)
  

  
  #location error
  output$error <- renderUI(
    if(location() == "error"){
      HTML("<font color='red'>Please enter a valid location</font>")
    }
    else{
      HTML("")
    }
  )
  

 

  ##################################
  #         Render Map
  ##################################

  output$map <- renderLeaflet({
    if(!(input$bullyingEnable | input$governmentEnable | input$catholicEnable | input$independentEnable | input$bullyingEnable)){
      map <- leaflet(LGA2, leafletOptions(maxZoom = 15))
      map <- map %>% addTiles()
      map <- map %>% setView(lat = -37.814, lng = 144.96332, zoom = 13)
    }
    else if(input$governmentEnable | input$catholicEnable | input$independentEnable){
      #Render map environment  
      map <- leaflet(LGA2, leafletOptions(maxZoom = 15))
      map <- map %>% addTiles()  
      if(!(location() %in% c("error", "nothing")))
      {
        map <- map %>% setView(lat = location()$lat, lng = location()$lon, zoom = 13) 
      }
      else{
        map <- map %>% setView(lat = -37.814, lng = 144.96332, zoom = 13)
      }
      
      
      #Check Bullying enabled if so add bullying
      if(input$bullyingEnable == TRUE){
        map <- map %>% addPolygons(
          fillColor = ~pal(LGA2@data$Indicator),
          weight = 1,
          fillOpacity = 0.5,
          popup = paste(LGA2$LGA, "<br>Bullying Rate: ",LGA2$Indicator,"%")
        )
        map <- map %>% addLegend("bottomright", pal = pal, values = ~bins,
                                 title = "Rate of Bullying (area)",
                                 labFormat = labelFormat(prefix = "%"),
                                 opacity = 1
        )
      }
      
      #check LGBT eabled if so add icons and legend
      if((input$lgbtEnable == TRUE) & !is.null(primary3())){
        #set safe school icon
        
        schoolIcons <- icons(
          iconUrl = getIcons(),
          iconWidth = primary3()$totalScaled, iconHeight = primary3()$totalScaled
        )
        #Set safe school legend
        
        output$legendItem1<- renderUI({x<-"<b>Safe Schools Member (LGBTI Support)</b>" 
        HTML(x)})
        output$legendItem1pic <- renderUI(img(src="https://image.ibb.co/kfEbWa/icons8_LGBT_Flag_48.png"))
      }
      else{
        #Set legends otherwise
        schoolIcons <- icons(
          iconUrl = getIcons(),
          iconWidth = primary3()$totalScaled, iconHeight = primary3()$totalScaled
        )
        output$legendItem1<- renderUI({x<-"" 
        HTML(x)})
        output$legendItem1pic <- renderUI("")
      }
      
      #Add icons to map
      if(!is.null(primary3()) & (input$governmentEnable | input$catholicEnable | input$independentEnable))
      {
        map <- map %>% addMarkers(lng=primary3()$Longitude, 
                                  lat=primary3()$Latitude, 
                                  label = paste(primary3()$School_Name,", Students: ",as.integer(primary3()$Total)),
                                  icon = schoolIcons,
                                  clusterOptions = markerClusterOptions(zoomToBoundsOnClick = TRUE, showCoverageOnHover = TRUE))
      }
      
      #School Type Legend
      if(input$governmentEnable == TRUE){
        output$legendGovernment <- renderUI({
          x<-"<b>Government School</b>" 
          HTML(x)
        })
        output$legendGovernmentPic <- renderUI(img(src="https://thumb.ibb.co/jaf3Ba/icons8_School_48.png"))
      }
      if(input$catholicEnable == TRUE){
        output$legendCatholic <- renderUI({
          x<-"<b>Catholic school</b>" 
          HTML(x)
        })
        output$legendCatholicPic <- renderUI(img(src="https://thumb.ibb.co/deESP5/icons8_School_48_Catholic.png"))
      }
      if(input$independentEnable == TRUE){
        output$legendIndependent <- renderUI({
          x<-"<b>Independent (Private) school</b>" 
          HTML(x)
        })
        output$legendIndependentPic <- renderUI(img(src="https://thumb.ibb.co/bMJXrk/icons8_School_48_Independent.png"))
      }
      
      #Bind map to victoria
      map <- map %>% setMaxBounds(140.8728, -34.01609,  150.8931, -39.13368)
      return(map)
    }
    else{
      map <- leaflet(LGA2, leafletOptions(maxZoom = 15))
      map <- map %>% addTiles()
      map <- map %>% setView(lat = -37.814, lng = 144.96332, zoom = 13)
    }
  })
  

})