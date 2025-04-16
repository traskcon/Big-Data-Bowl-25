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
#get_color <- function(route_epa, route) {
#  filter(route_epa, routeRan == route)$color
#} 

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


# Define UI for application that draws a histogram
ui <- page_navbar(
  title = "Route Visualizer",
  nav_panel("Routes by Team",
    layout_sidebar(
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
        gap = 5,
        uiOutput("go"),
        uiOutput("hitch"),
        uiOutput("flat"),
        uiOutput("out"),
        uiOutput("cross"),
        uiOutput("ins"),
        uiOutput("post"),
        uiOutput("slant"),
        uiOutput("corner"),
        uiOutput("screen"),
        uiOutput("angle"),
        uiOutput("wheel")
      ),
      cards[[1]]
    )
  ),
  nav_panel("Player Routes")
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
  go <- reactive({
    filter(route_epa(), routeRan == "GO")
  })
  out <- reactive({
    filter(route_epa(), routeRan == "OUT")
  })
  hitch <- reactive({
    filter(route_epa(), routeRan == "HITCH")
  })
  flat <- reactive({
    filter(route_epa(), routeRan == "FLAT")
  })
  cross <- reactive({
    filter(route_epa(), routeRan == "CROSS")
  })
  ins <- reactive({
    filter(route_epa(), routeRan == "IN")
  })
  post <- reactive({
    filter(route_epa(), routeRan == "POST")
  })
  slant <- reactive({
    filter(route_epa(), routeRan == "SLANT")
  })
  corner <- reactive({
    filter(route_epa(), routeRan == "CORNER")
  })
  screen <- reactive({
    filter(route_epa(), routeRan == "SCREEN")
  })
  angle <- reactive({
    filter(route_epa(), routeRan == "ANGLE")
  })
  wheel <- reactive({
    filter(route_epa(), routeRan == "WHEEL")
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
  output$go <- renderUI({
    value_box(
    title = "Go",
    value = specify_decimal(go()$epa, 4),
    showcase = bs_icon("arrow-up"),
    theme = value_box_theme(bg=as.character(go()$color))
    )
  })
  output$hitch <- renderUI({
    value_box(
      title = "Hitch",
      value = specify_decimal(hitch()$epa, 4),
      showcase = bs_icon("4-square"),
      theme = value_box_theme(bg=as.character(hitch()$color))
    )
  })
  output$flat <- renderUI({
    value_box(
      title = "Flat",
      value = specify_decimal(flat()$epa, 4),
      showcase = bs_icon("arrow-left"),
      theme = value_box_theme(bg=as.character(flat()$color))
    )
  })
  output$out <- renderUI({
    value_box(
      title = "Out",
      value = specify_decimal(out()$epa, 4),
      showcase = bs_icon("arrow-90deg-left"),
      theme = value_box_theme(bg=as.character(out()$color))
    )
  })
  output$cross <- renderUI({
    value_box(
      title = "Cross",
      value = specify_decimal(cross()$epa, 4),
      showcase = bs_icon("arrow-up-right"),
      theme = value_box_theme(bg=as.character(cross()$color))
    )
  })
  output$ins <- renderUI({
    value_box(
      title = "In",
      value = specify_decimal(ins()$epa, 4),
      showcase = bs_icon("arrow-90deg-right"),
      theme = value_box_theme(bg=as.character(ins()$color))
    )
  })
  output$post <- renderUI({
    value_box(
      title = "Post",
      value = specify_decimal(post()$epa, 4),
      showcase = bs_icon("8-square"),
      theme = value_box_theme(bg=as.character(post()$color))
    )
  })
  output$slant <- renderUI({
    value_box(
      title = "Slant",
      value = specify_decimal(slant()$epa, 4),
      showcase = bs_icon("2-square"),
      theme = value_box_theme(bg=as.character(slant()$color))
    )
  })
  output$corner <- renderUI({
    value_box(
      title = "Corner",
      value = specify_decimal(corner()$epa, 4),
      showcase = bs_icon("7-square"),
      theme = value_box_theme(bg=as.character(corner()$color))
    )
  })
  output$screen <- renderUI({
    value_box(
      title = "Screen",
      value = specify_decimal(screen()$epa, 4),
      showcase = bs_icon("arrow-return-right"),
      theme = value_box_theme(bg=as.character(screen()$color))
    )
  })
  output$angle <- renderUI({
    value_box(
      title = "Angle",
      value = specify_decimal(angle()$epa, 4),
      showcase = bs_icon("arrow-up-left"),
      theme = value_box_theme(bg=as.character(angle()$color))
    )
  })
  output$wheel <- renderUI({
    value_box(
      title = "Wheel",
      value = specify_decimal(wheel()$epa, 4),
      showcase = bs_icon("vinyl-fill"),
      theme = value_box_theme(bg=as.character(wheel()$color))
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
