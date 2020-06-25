## ---------------------------------------------------------
## R Script voor interactieve data-analyse van sensordata, met o.a. packages zoals 'shiny', 'leaflet' en 'openair'.     
## Dit platform bestaat uit meerdere scripts. Dit is het selectReactiveComponent.R script.
## Auteurs: 
## (Fundatie platform) Henri de Ruiter en Elma Tenner namens het Samen Meten Team, RIVM. 
## (Uitbreiding platform) Thomas Geurts van Kessel en Stefan Knoet namens de HAS en Radboud Universiteit 
## Laatste versie: juni 2020
## ---------------------------------------------------------
## Opmerkingen: 
## Het eerste deel bevat de interactieve component voor de fijnstofwaarden.
## Het tweede deel bevat de interactieve component voor de tijdslider.
## ---------------------------------------------------------

## Gedeelte 1 ----
# Interactieve component voor het selecteren van de fijnstofwaarden in de toolbox.
selectReactiveComponent <- function(input){ 
  
comp <- switch(input$Var, 
               "PM10" = "pm10",
               "PM10 - gekalibreerd" = "pm10_kal",
               "PM2.5" = "pm25",
               "PM2.5 - gekalibreerd" = "pm25_kal")

  return(comp)
} 

## Gedeelte 2 ----
# Interactieve component voor de timeslider; selectie datum en tijd in de toolbox.
selectReactiveDates <- function(input){ 
  
  dates_reactive <- reactive({
    start <-   format(as.POSIXct(input$TimeRange[1],format='%Y-%m-%d %H:%M:%S'),format='%d/%m/%Y')
    end <- format(as.POSIXct(input$TimeRange[2],format='%Y-%m-%d %H:%M:%S'),format='%d/%m/%Y')
    
    combo <- list(start = start, end = end)
    combo
  })
  
} 
  