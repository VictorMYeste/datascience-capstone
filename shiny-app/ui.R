# title: "Data Science Capstone"
# author: "Víctor Yeste"
# date: "10/20/2021"

library(shiny)

# Define UI for application

shinyUI(
    navbarPage("Data Science Capstone",
       tabPanel("Home",
                fluidPage(
                    
                    # Application title
                    
                    titlePanel("Data Science Capstone"),
                    img(src="coursera.png", align = "center", width = 200),
                    br(),
                    br(),
                    
                    # Sidebar with a text and slider input
                    
                    sidebarLayout(
                        sidebarPanel(
                            textInput("userText",
                                      "Write a word or a phrase",
                                      value = ""),
                            br(),
                            sliderInput("nPred", "Number of Predictions", value = 1.0, min = 1.0,
                                        max = 3.0, step = 1.0)
                        ),
                        
                        # Show the text and the predictions
                        
                        mainPanel(
                            h3("Text introduced"),
                            verbatimTextOutput("userTextResult"),
                            br(),
                            h3("Prediction 1"),
                            verbatimTextOutput("pred1"),
                            h3("Prediction 2"),
                            verbatimTextOutput("pred2"),
                            h3("Prediction 3"),
                            verbatimTextOutput("pred3")
                        )
                    )
                )
       ),
       tabPanel("Project Overview",
                h3("Project Overview"),
                br(),
                p("Around the world, people are spending an increasing amount of time on their mobile devices for email, social networking, banking and a whole range of other activities. But typing on mobile devices can be a serious pain."),
                br(),
                p("This is a data product that helps you predict the next word after a word or a phrase, based on several files with content in English. Just put your text in the field of the sidebar and select up to three word predictions with the slider."),
                br(),
                p("This project has been developed by Víctor Yeste, for the", a(target = "_blank", href = "https://www.coursera.org/learn/data-science-project?specialization=jhu-data-science", "Data Science Capstone of Coursera"), ", final course of the specialized program of ", a(target = "_blank", href = "https://www.coursera.org/specializations/jhu-data-science", "Data Science"), " offered by Johns Hopkins University."),
                br(),
                p("You can find the source of this application on ", a(target = "_blank", href = "https://github.com/VictorMYeste/datascience-capstone", "GitHub"), ".")
       )
    )
)