## ---------------------------------------------------------
## R Script voor interactieve data-analyse van sensordata, met o.a. packages zoals 'shiny', 'leaflet' en 'openair'.     
## Dit platform bestaat uit meerdere scripts. Dit is het tabPanels.R script.
## Auteurs: 
## (Fundatie platform) Henri de Ruiter en Elma Tenner namens het Samen Meten Team, RIVM. 
## (Uitbreiding platform) Thomas Geurts van Kessel en Stefan Knoet namens de HAS en Radboud Universiteit 
## Laatste versie: juni 2020
## ---------------------------------------------------------
## Opmerkingen: 
## (Dit bestand maakt deel uit van de toolbox)
## Het eerste deel bevat het tablad met het tijdreeks plot.
## Het tweede deel bevat de tabbladen met de kalender plots.
## Het derde deel bevat het tabblad met het gemiddelden plot.
## Het vierde deel bevat de tabbladen met de interactieve grafieken.
## Het vijfde deel bevat het tabblad met de downloadmogelijkheid.
## ---------------------------------------------------------

## Gedeelte 1 ----
# Tijdreeks tabblad voor PM10 en PM2,5.
tpTimeplot <- function(){
  
library(shiny)
  
 tp <-  tabPanel("Tijdreeks",
                 
                sidebarLayout(
                  sidebarPanel(id = "sidebar",
                    
                    h4("Toelichting"),
                    p("Als je een sensor aanklikt zie je een tijdreeks van de gemeten waarden die per uur zijn vastgelegd in de geselecteerde periode. 
                      Deze waarden worden vergeleken met de bijhorende gekalibreerde waarden. Dit maakt het mogelijk om  te kijken of de huidige waarden 
                      worden beïnvloed door enige externe factoren (zoals weersinvloeden).",
                      style = "font-size:12px"),
                      br(),
                      helpText("Download plot"),
                      downloadHandler('downloadTimePlot', 'Download'),
                      
                    width = 3),
                
                  mainPanel(
                    helpText("Deze grafiek laat de uurwaardes van de aangeklikte sensoren zien (PM 10 - PM 2,5)"),
                    plotOutput("timeplot"),
                    width = 9),
                  position = "right",
                  fluid = TRUE),
                
 )
          
  return(tp)
} 

## Gedeelte 2 ----

# Kalender tabblad voor PM10.
tpKalender1 <- function(){
  
  library(shiny)
  
  tp <-  tabPanel("Kalender PM 10",
                  
                  sidebarLayout(
                    sidebarPanel(id = "sidebar",
                      h4("Toelichting"),
                      p("Als je een sensor aanklikt, wordt de gemiddelde concentratie per dag getoond in een standaard kalenderformaat. 
                        Dit maakt het mogelijk om snel inzicht te krijgen op welke dagen de concentraties hoog (of laag) waren. 
                        Op dit moment worden de kleuren gekozen op basis van een schaal van 0 tot 50 (gebaseerd op PM 10 dagwaardes). 
                        Concentraties in de buurt van 50 worden donkerrood.",
                        style = "font-size:12px"),
                      br(),
                      helpText("Download plot"),
                      downloadButton('downloadKal10', 'Download'),
                      
                      width = 3),
                    mainPanel(
                      helpText("Laat een kalender van de aangeklikte sensoren zien (PM 10)"),
                      plotOutput("calendar1"),
                      width = 9),
                    position = "right")
              )

return(tp)
}

# Kalender tabblad voor PM2,5.
tpKalender2 <- function(){
    
    library(shiny)
    
    tp <-  tabPanel("Kalender PM 2,5",
                    
                    sidebarLayout(
                      sidebarPanel(id = "sidebar",
                                   h4("Toelichting"),
                                   p("Als je een sensor aanklikt, wordt de gemiddelde concentratie per dag getoond in een standaard kalenderformaat. 
                                     Dit maakt het mogelijk om snel inzicht te krijgen op welke dagen de concentraties hoog (of laag) waren. 
                                     Op dit moment worden de kleuren gekozen op basis van een schaal van 0 tot 25 (gebaseerd op PM 2,5 dagwaardes). 
                                     Concentraties in de buurt van 25 worden donkerrood.",
                                     style = "font-size:12px"),
                                   br(),
                                   helpText("Download plot"),
                                   downloadButton('downloadKal25', 'Download'),
                                   
                                   width = 3),
                      mainPanel(
                        helpText("Laat een kalender van de aangeklikte sensoren zien (PM 2,5)"),
                        plotOutput("calendar2"),
                        width = 9),
                      position = "right")
    )
  
  return(tp)
} 

## Gedeelte 3 ----
# Gemiddelden tabblad voor PM10 PM2,5 en gekalibreerde waarden.
tpTimevariation <- function(){
  
  library(shiny)
  
  tp <-  tabPanel("Gemiddelden",
                  sidebarLayout(
                    sidebarPanel(id = "sidebar",
                      h4("Toelichting"),
                      p("Als je een sensor aanklikt wordt de gemiddelde concentratie per tijdsperiode getoond. 
                        De bovenste grafiek laat de gemiddelde uurwaarde, uitgesplitst naar weekdag, zien. 
                        Onder zie je de gemiddelde concentratie op elk uur van de dag (links), in het midden zie je de gemiddelde concentratie per maand 
                        en rechts zie je de gemiddelde concentratie per dag van de week.",
                        style = "font-size:12px"),
                        br(),
                        helpText("Download plot"),
                        downloadButton('downloadGemPlot', 'Download'),
                        
                      width = 3),
                    mainPanel(
                      helpText("Deze grafiek laat het gemiddelde van de aangeklikte sensoren zien"),
                      plotOutput("timevariation"),
                      width = 9),
                    position = "right")
                  )
  
  return(tp)
} 

## Gedeelte 4 ----
# Interactieve grafiek tabblad voor PM10.
tpInterplot <- function(){
  
  library(shiny)
  
  tp <-  tabPanel("Grafiek PM 10",
                  sidebarLayout(
                    sidebarPanel(id = "sidebar",
                                 h4("Toelichting"),
                                 p("Bij selectie van een sensor wordt de PM 10 waarde over een bepaald tijdsbestek getoond. 
                                 Hierbij is selectie van meerdere sensoren mogelijk. De grafiek bevat een aantal functionaliteiten 
                                 (legenda en extra functies) om de data beter te bekijken, vergelijken en analyseren. 
                                 Er is ook de mogelijkheid om de grafiek te downloaden (PNG formaat).",
                                   style = "font-size:12px"),
                                 width = 3),
                    mainPanel(
                      helpText("Laat een grafiek van de aangeklikte sensoren zien (PM 10)"),
                      plotlyOutput("interplot"),
                      width = 9),
                    position = "right"))
  
  return(tp)
} 

# Interactieve grafiek tabblad voor PM2,5.
tpInterplot2 <- function(){
  
  library(shiny)
  
  tp <-  tabPanel("Grafiek PM 2,5",
                  sidebarLayout(
                    sidebarPanel(id = "sidebar",
                                 h4("Toelichting"),
                                 p("Bij selectie van een sensor wordt de PM 2,5 waarde over een bepaald tijdsbestek getoond. 
                                 Hierbij is selectie van meerdere sensoren mogelijk. De grafiek bevat een aantal functionaliteiten 
                                 (legenda en extra functies) om de data beter te bekijken, vergelijken en analyseren. 
                                 Er is ook de mogelijkheid om de grafiek te downloaden (PNG formaat).",
                                   style = "font-size:12px"),
                                 width = 3),
                  mainPanel(
                    helpText("Laat een grafiek van de aangeklikte sensoren zien (PM 2,5)"),
                    plotlyOutput("interplot_n"),
                    width = 9),
                  position = "right"))
  
  return(tp)
} 

## Gedeelte 5 ----
# Download tabblad voor individuele sensoren.
tpDownload<- function(){
  
  library(shiny)
  
  tp <-  tabPanel("Downloaden",
                  sidebarLayout(
                    sidebarPanel(id = "sidebar",
                                 h4("Toelichting"),
                                 p("De sensoren in de toolbox kunnen gedownload worden. 
                                   In het drop-down menu kan een specifieke sensor-ID worden geselecteerd. 
                                   Vervolgens kan er een download formaattype geselecteerd worden. 
                                   Wanneer beide elementen zijn ingevuld en je op de download knop klikt, 
                                   wordt het desbetreffende bestand lokaal opgeslagen op je apparaat.",
                                   style = "font-size:12px"),
                                 width = 3),

                    mainPanel(
                      selectInput("dataset", "Selecteer de sensor",
                                  choices = c("LTD_22481", "LTD_24283", "LTD_24322", "LTD_24801", "LTD_25494", "LTD_27239", "LTD_27720", "LTD_31298")),
                      br(),
                      helpText("Selecteer het downloadformaat"),
                      radioButtons("type", "Formaat type:",
                                   choices = c("Excel (CSV)", "Text (TSV)", "Text (Space Separated)", "Doc")),
                      br(),
                      helpText("Klik op de download knop om de geselecteerde sensor te downloaden"),
                      downloadButton('downloadData', 'Download'),
                      width = 9),
                  position = "right"))

  return(tp)
} 

