#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(ggplot2)
library(bslib)
library(bsicons)
library(RColorBrewer)

# Define useful functions
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))

# Load data from csv files on app start
pp_data <- read_csv("player_play.csv") |>
  drop_na(routeRan) |>
  select(nflId, gameId, playId, hadPassReception, routeRan, wasTargettedReceiver, teamAbbr)

play_data <- read_csv("plays.csv") |>
  select(gameId, playId, expectedPointsAdded, pff_passCoverage)

player_data <- read_csv("players.csv") |>
  select(nflId, displayName)

# Merge data sources into unified dataframe
main_data <- merge(player_data, merge(pp_data, play_data))

# Define reusable inputs & displays
cards <- list(
  card(
    min_height = 400,
    card_header("Route Distribution"),
    plotOutput("routeDist")
  )
)
vbs <- list(
  value_box(
    title = "Go",
    value = textOutput("go"),
    showcase = bs_icon("arrow-up"),
    theme = get_color()
  ),
  value_box(
    title = "Hitch",
    value = textOutput("hitch"),
    showcase = bs_icon("4-square")
  ),
  value_box(
    title = "Flat",
    value = textOutput("flat"),
    showcase = bs_icon("arrow-left")
  ),
  value_box(
    title = "Out",
    value = textOutput("out"),
    showcase = bs_icon("arrow-90deg-left")
  ),
  value_box(
    title = "Cross",
    value = textOutput("cross"),
    showcase = bs_icon("arrow-up-right")
  ),
  value_box(
    title = "In",
    value = textOutput("ins"),
    showcase = bs_icon("arrow-90deg-right")
  ),
  value_box(
    title = "Post",
    value = textOutput("post"),
    showcase = bs_icon("8-square")
  ),
  value_box(
    title = "Slant",
    value = textOutput("slant"),
    showcase = bs_icon("2-square")
  ),
  value_box(
    title = "Corner",
    value = textOutput("corner"),
    showcase = bs_icon("7-square")
  ),
  value_box(
    title = "Screen",
    value = textOutput("screen"),
    showcase = bs_icon("arrow-return-right")
  ),
  value_box(
    title = "Angle",
    value = textOutput("angle"),
    showcase = bs_icon("arrow-up-left")
  ),
  value_box(
    title = "Wheel",
    value = textOutput("wheel"),
    showcase = bs_icon("vinyl-fill")
  )
)


# Define UI for application that draws a histogram
ui <- page_sidebar(
  title = "Route Visualizer",
  sidebar = sidebar(
    selectInput("team",
                "Team:",
                c("NFL",unique(main_data$teamAbbr)),
                selected = "NFL"),
    checkboxInput("targets",
                  "Targets Only:",
                  value = FALSE)
  ),
  layout_columns(
    fill = FALSE,
    !!!vbs
  ),
  cards[[1]]
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # If no team has been selected, return NFL stats, otherwise filter for specific team
  route_data <- reactive({
    if (input$team == "NFL")  {
      if (input$targets) {
        main_data |>
          filter(wasTargettedReceiver == 1)
      } else {
      main_data
      }
    } else {
      if (input$targets) {
        main_data |>
          filter(wasTargettedReceiver == 1, teamAbbr == input$team)
      } else {
        main_data |>
          filter(teamAbbr == input$team)
      }
    }
  })
  route_epa <- reactive({
    route_data() |>
      group_by(routeRan) |>
      summarise(epa = mean(expectedPointsAdded)) |>
      mutate(color = cut(epa, c(-Inf,-2,-1.5,-1,-0.5,-0.1,0.1,0.5,1,1.5,2,Inf),
                         labels=c("#8E0152","#C51B7D","#DE77AE","#F1B6DA","#FDE0EF","#F7F7F7","#E6F5D0","#B8E186","#7FBC41","#4D9221","#276419")))
  })
  get_color <- reactive({
    filter(route_epa(), routeRan == "GO")$color
  })
  
  # Plot route distribution
  output$routeDist <- renderPlot({
      route_counts <- route_data() |>
        count(routeRan, sort=TRUE) 
      # Make bar plot
      ggplot(data=route_counts, aes(x=reorder(routeRan,-n),y=n)) +
        geom_bar(stat="identity") +
        xlab("Route Run") +
        ylab("Number of times run")
    })
  output$go <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "GO")$epa, 4)
    })
  output$hitch <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "HITCH")$epa, 4)
  })
  output$flat <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "FLAT")$epa, 4)
  })
  output$out <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "OUT")$epa, 4)
  })
  output$cross <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "CROSS")$epa, 4)
  })
  output$ins <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "IN")$epa, 4)
  })
  output$post <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "POST")$epa, 4)
  })
  output$slant <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "SLANT")$epa, 4)
  })
  output$corner <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "CORNER")$epa, 4)
  })
  output$screen <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "SCREEN")$epa, 4)
  })
  output$angle <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "ANGLE")$epa, 4)
  })
  output$wheel <- renderText({
    specify_decimal(filter(route_epa(), routeRan == "WHEEL")$epa, 4)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
