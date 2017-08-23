require(shiny)
require(leaflet)
require(shinydashboard)
require(shinycssloaders)



shinyUI(dashboardPage(skin = "green",
  dashboardHeader(title = "EduWell School Finder"),
  dashboardSidebar(
    tags$style(HTML("
                    .main-header{background-colour:rgba(30, 190, 103, 1)}
                    .sidebar{margin-left:10px; overflow:scroll;max-height:650px}
                    .main-sidebar { width: 200px;overflow-y: auto; padding-top:0px; background-colour:rgba(30, 190, 103, 1)}
                    .skin-green .left-side, .skin-green .main-sidebar, .skin-green .wrapper {background-color: rgba(27, 155, 51, 1);}                      
                    .skin-green.main-sidebar{
                    background-color:rgba(30, 190, 103, .90);
                    }
                    .col-lg-1, .col-lg-10, .col-lg-11, .col-lg-12, .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-5, .col-lg-6, .col-lg-7, .col-lg-8, .col-lg-9, .col-md-1, .col-md-10, .col-md-11, .col-md-12, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .col-sm-1, .col-sm-10, .col-sm-11, .col-sm-12, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .col-sm-6, .col-sm-7, .col-sm-8, .col-sm-9, .col-xs-1, .col-xs-10, .col-xs-11, .col-xs-12, .col-xs-2, .col-xs-3, .col-xs-4, .col-xs-5, .col-xs-6, .col-xs-7, .col-xs-8, .col-xs-9{
                    padding-right:0px;
                    }
                    .leaflet .legend i{
                    border-radius: 50%;
                    width:10px;
                    height: 10px;
                    margin-top: 4px;
                    }
                    .leaflet .legend{
                    width:120px;
                    height: auto;
                    margin-top: 4px;
                    }
                    .marker-cluster-small div{
                    background-image = http://35.189.25.144/wp-content/uploads/2017/08/cropped-cropped-logo.png;
                    }
                    .input-group{
                    background-color: #55b93c;
                    padding-top: 10px;
                    padding-bottom: 10px
                    }
                    .sidebar .shiny-bound-input.action-button, section.sidebar .shiny-bound-input.action-link{
                      margin: -1px 0px 0px 10px
                    }
                    .DISABLED{
                      min-height: 100VH !important
                    }
                    .skin-green .sidebar-form .btn{
                    background-color: rgba(125, 125, 128, 0.34);
                    }
                    ")
    ),
    tags$script(' $(document).on("keydown", function (e) {
                                                  if(e.keyCode == 13){
                                                      Shiny.onInputChange("keypress", Math.random());
                                                  }

                });
                '),
    
    h3("Filters"),
    h4("Area"),
    textInput("n","Enter your location (Suburb or Postcode)", value = "Melbourne"),
    htmlOutput("error"),
    actionButton("go", "Go"),
    br(),
    br(),
    h4(" Local Government Area Data"),
    checkboxInput("bullyingEnable","Rates of Bullying (by local governement area)", value = TRUE),
    h4(" School Type"),
    checkboxInput("governmentEnable","Government", value = TRUE),
    checkboxInput("catholicEnable","Catholic", value = TRUE),
    checkboxInput("independentEnable","Independent", value = TRUE),
    h4("Programs Offered"),
    checkboxInput("lgbtEnable","Safe Schools (LGBTIA Support)", value = TRUE)

  ),
  dashboardBody( class="DISABLED",

      box(width=9, height = "100%",
             withSpinner(leafletOutput("map",height="600px"), type = 6, color = "#6BBE67"),
             textOutput("locationText", inline = TRUE) 
             ),
      box(width = 3, height = "200px",
          h4(textOutput("schoolName")),
          htmlOutput("schoolType"),
          htmlOutput("schoolAddress"),
          htmlOutput("schoolPhone"),
          htmlOutput("studentQty")),
      box(width = 3, style="height: 400px;overflow:scroll;",
          h3("Legend"),
          htmlOutput("legendCluster", inline = TRUE),
          htmlOutput("legendlegendClusterPic"),
          h4("Schools Types (sized by school size)"),
          span(htmlOutput("legendGovernment", inline = TRUE),htmlOutput("legendGovernmentPic"), inline = TRUE),
          htmlOutput("legendIndependent", inline = TRUE),
          htmlOutput("legendIndependentPic"),
          htmlOutput("legendCatholic", inline = TRUE),
          htmlOutput("legendCatholicPic"),
          htmlOutput("legendItem1", inline = TRUE),
          h4("Diversity and Support"),
          htmlOutput("legendItem1pic")
      ))

))