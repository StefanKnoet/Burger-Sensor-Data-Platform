## ---------------------------------------------------------
## R Script voor interactieve data-analyse van sensordata, met o.a. packages zoals 'shiny', 'leaflet' en 'openair'.     
## Dit platform bestaat uit meerdere scripts. Dit is het ui.R script.
## Auteurs: 
## (Fundatie platform) Henri de Ruiter en Elma Tenner namens het Samen Meten Team, RIVM. 
## (Uitbreiding platform) Thomas Geurts van Kessel en Stefan Knoet namens de HAS en Radboud Universiteit 
## Laatste versie: juni 2020
## ---------------------------------------------------------
## Opmerkingen: 
## Het eerste gedeelte bevat de opmaak van het platform
## Het tweede gedeelte bevat de functionaliteiten van het platform
## ---------------------------------------------------------

## Gedeelte 1 ----
# Hier worden de bestand opgehaald die de vormgeving van het platform waarborgd.
# De originele opmaak is in enige mate aangepast.
# Het bestand wat van toepassing is, is het template.wide.html bestand.
# Het desbetreffende HTML bestand staat in de map 'www'.

# HTML template voor de opmaak/styling
htmlTemplate("./www/template.wide.html",
             pageTitle=paste("Smart Emission 2, deelproject 2: ", projectnaam),

## Gedeelte 2 ----
# Vanaf hier begint het platform zelf.
# Het platform bevat een aantal belangrijke functionaliteiten.
# De basis, die is gelegd, komt voort uit het Hollandse Luchten platform van het RIVM
# Vanuit de basis zijn er een aantal elementen toegevoegd.
  
  fluidPage=fluidPage(
    navbarPage("",
               
  # In de onderste code wordt verwezen naar de toolbox met verschillende functies. 
  # De data uit de Samen Meten API wordt in de toolbox weergegeven              
  tabPanel("Toolbox",

  # wellPanel voor grijze boxing
  wellPanel(
  # Sidebar layout met input en output definities
  sidebarLayout(
    # Sidebar panel voor leaflet map om sensoren te selecteren
    sidebarPanel(
      
      #Output: Leaflet map voor sensorselectie
      leafletOutput("map", height = "300px"),
      br(),
      
      fluidRow(
        column(7,# Input: Selecteer de component uit de choices lijst
               selectInput(inputId = "Var", label = "Kies component", choices = choices, selected = NULL, multiple = FALSE,
                           selectize = TRUE, width = NULL, size = NULL)
        ),
        column(5, # Button om de selectie van sensoren te resetten
               actionButton("reset", "Reset selectie")
        )
        
        
      ),
      
      fluidRow(
        column(7,# Input: Tekst voor de groepselectie
               textInput(inputId = "Text_groep",'Vul groepsnaam in', value = 'groep1')
        )
        ,
        column(5, # Input: Checkbox om aan te vinken om de sensoren in een groep te plaatsen
               checkboxInput('A_groep','Voeg selectie toe aan groep')
        )
      )
      ,
      # Input: Slider voor het genereren van de tijdreeks
      sliderInput("TimeRange", label = "Selecteer tijdreeks",
                  min = min(input_df$date),
                  max = max(input_df$date),
                  step=60*60*24,
                  value = c(min(input_df$date),
                            max(input_df$date)
                            
                  ),
                  width = '100%'
      )
    ),
    
    # Main panel voor de outputs
    mainPanel(
      # Output: Tabset voor openair plots en andere functionaliteiten, zie voor de inhoud het script: tabPanels.R
      tabsetPanel(type = "tabs",
                  tpTimeplot(),
                  tpKalender1(),
                  tpKalender2(),
                  tpTimevariation(),
                  tpInterplot(),
                  tpInterplot2(),
                  tpDownload()
             )
           ) 
         )
       )
     ),
  
  # Vervolgens moesten de nieuwe funtionaliteiten ook een plek krijgen binnen het platform. 
  # Om dit te waarborgen zijn er nieuwe tablpanels gemaakt.
  # In elke tabpanel wordt een individuele functie geplaatst.
  # Deze zijn hieronder weergegeven.
  
  # In de onderste code wordt verwezen naar de grote kaart met aanwezige sensordata visualisatie. 
  # De data uit de Luftdaten API wordt in de kaart weergegeven.
  tabPanel("Kaart",
           leafletOutput("MyMap", width = "1800px", height = "700px"),
           
           absolutePanel(bottom = 0, left = 260, fixed = TRUE, class = "panel panel-default", 
                         width = 320, style = "opacity: 0.8;", 
                         chooseSliderSkin("Flat", color = "#112446"),
                         sliderInput("range", "Selecteer Meetwaardes", min(0), max(60),
                                     value = range(API_Luftdaten$P1), step = 1)
           )),
  
  # In de onderste code wordt verwezen naar de tabel van de 'Samen Meten' API.
  # De data uit deze tabel wordt weergegeven in de toolbox.
  tabPanel("Tabel (API Samen Meten)",
           fluidRow(
             column(10,
                    DTOutput('table_overviewSam')
             ))),
  
  # In de onderste code wordt verwezen naar de tabel van de 'Luftdaten' API.
  # De data uit deze tabel wordt weergegeven in de kaart.    
  tabPanel("Tabel (API Luftdaten)",
           fluidRow(
             column(10,
                    DTOutput('table_overviewLuft')
             ))),
  
  # In de onderste code wordt verwezen naar de 'over de app' tab met informatie over het platform en dergelijke.
  # Alle belangrijke informate wordt weergegeven op deze pagina.
  tabPanel("Over De App",
        mainPanel(
          br(),
          
          h4("Het platform"),
          p("Het platform bestaat uit verschillende tools. Met behulp van deze tools kunnen gebruikers, in dit geval burgers en experts, op een functionele en gebruiksvriendelijke manier fijnstof sensor data bekijken, 
            analyseren en visualiseren. Het dashboard focust zich op een 'use case' voor het",
          a("Arnhem's Peil.",
          href = "https://www.arnhemspeil.nl/index.html", target = 'blank'),
           "Hiermee wordt het voor burgers in Arnhem mogelijk gemaakt om inzichten te krijgen in milieukwaliteiten in een gebied van interesse. 
          Het platform is specifiek ontwikkeld voor het weergeven van fijnstof sensor data, andere milieukwaliteiten zoals luchtvochtigheid en temperatuur zijn niet meegenomen in het platform."),
          p("Het uiteindelijke doel van het platform:  het verlagen van de drempel om gebruik te maken van sensordata,  ondersteuning bieden bij het uitvoeren van een analyse en het stimuleren van burgerwetenschap."),
          
          h4("Verantwoording"),
          p("Voor de ontwikkeling van het platform in RStudio is - in overeenkomst met het RIVM - besloten om de R-scripts van het Hollandse Luchten platform te gebruiken als fundatie. 
            De benodigde bestanden van het Hollandse Luchten platform zijn te vinden in de volgende link:",
          a("'Bestanden Hollandse Luchten platform'.",
          href = "https://github.com/rivm-syso/Samen-analyseren-tool", target = 'blank')),
          p("Het platform is een prototype. Dit betekent dat deze nog volop in ontwikkeling is. 
            De huidige functionaliteiten, zoals de grafieken, tabellen en kaarten, kunnen aangepast worden. 
            Het doel van het platform is het testen van mogelijke analyses en visualisaties van sensor data 
            die met behulp van APIs ingeroepen worden (toevoegen broncode GITHUB)."),
          
          h4("Data"),
          p("De sensor data, die in het platform worden weergegeven, zijn afkomstig van fijnstof registrerende sensoren van",
          a("Luftdaten.",
          href = "https://luftdaten.info/nl/startpagina/", target = 'blank'),
           "Luftdaten valt onder het project OK Lab Stuttgart, dat onderdeel uitmaakt van het programma 'Code For Germany'. 
          Het doel van Code For Germany: het bevorderen van ontwikkeling op het gebied van onder andere transparantie en open data. 
          Hierdoor wordt het gebruikers mogelijk gemaakt om bij de sensor data te komen die worden verzameld. Sensor data, geregistreerd door Luftdaten sensoren, 
          worden beschikbaar gesteld via verschillende APIs. Deze APIs (Application Programming Interfaces) verzorgen de communicatie tussen twee verschillende applicaties. 
          APIs maken het dus mogelijk om gegevens van systeem naar systeem over te dragen, zoals wordt gedaan bij de geregistreerde sensorwaarden weergegeven in het platform. 
          De sensor data in het platform worden via twee APIs binnengehaald;",
           a("de Samen Meten API",
           href = "https://www.samenmetenaanluchtkwaliteit.nl/dataportaal/api-application-programming-interface", target = 'blank'),
           "en",
           a("de Luftdaten API.",
           href = "https://github.com/opendata-stuttgart/meta/wiki/EN-APIs", target = 'blank'),
          p("De desbetreffende APIs zijn in RStudio individueel ingeroepen en omgezet tot bewerkbare tabellen.
           Vervolgens zijn de tabellen bewerkt tot deze overeenkwamen met de dataset die in het Hollandse Luchten platform wordt gebruikt.
           Bij het inladen en verwerken van de APIs is er gekozen om de sensor data uit de APIs voor verschillende doeleinden te gebruiken;
           De Samen Meten API bevat historische data (max. 5 dagen), waardoor deze is gebruikt in de toolbox. 
           In de toolbox wordt de nadruk gelegd op het verwerken van de sensor data in plots en grafieken, waarbij de timestamp van de data een belangrijke rol speelt.
           De Luftdaten API bevat realtime data, waardoor deze is gebruikt in de kaart.
           In de kaart wordt de nadruk gelegd op het verwerken van de sensor data in een kaart, waarbij de timestamp van de data een minder belangrijke rol speelt."),
          p("Gedurende de ontwikkeling van het platform is er verder niet gelet op de ingeladen sensor data. De focus lag op het uitbreiden van de huidige functionaliteiten
            en het toevoegen van nieuwe functionaliteiten in het Hollandse Luchten Platform."),
          
          h4("Software"),
          p("Voor de ontwikkeling van het platform is het softwareprogramma",
          a("RStudio",
          href = "https://rstudio.com/products/rstudio/", target = 'blank'),  
          "gebruikt. RStudio is een ontwikkelomgeving voor de programmeertaal 'R'. 
          Met de programmeertaal R wordt een systeem opgebouwd uit objecten, waarbij elk object gegevens en een gegevensverwerker bevat. 
          Om dergelijke objecten te bouwen in RStudio, moet er gekeken worden welke 'R-packages' gedownload moeten worden. 
          Een R-package omvat een bibliotheek met specifieke functies. Voor de ontwikkeling van  het platform is bijvoorbeeld de R-Package ",
           a("'Shiny'",
          href = "https://shiny.rstudio.com/", target = 'blank'),
           "gebruikt. De bibliotheek van Shiny bevat functies waarmee gebruikers met RStudio applicaties kunnen ontwikkelen.")
        )
      )
    )
  )
)
)