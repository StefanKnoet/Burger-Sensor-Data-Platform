## ---------------------------------------------------------
## R Script voor interactieve data-analyse van sensordata, met o.a. packages zoals 'shiny', 'leaflet' en 'openair'.     
## Dit platform bestaat uit meerdere scripts. Dit is het server.R script.
## Auteurs: 
## (Fundatie platform) Henri de Ruiter en Elma Tenner namens het Samen Meten Team, RIVM. 
## (Uitbreiding platform) Thomas Geurts van Kessel en Stefan Knoet namens de HAS en Radboud Universiteit 
## Laatste versie: juni 2020
## ---------------------------------------------------------
## Opmerkingen: 
## Het eerste deel bevat het initialiseren van een basemap (toolbox) en reactieve datasets.
## Het tweede deel bevat functies voor de sensoren in de toolbox.
## Het derde deel bevat de observatie functionaliteiten.
## Het vierde deel bevat de plots, grafieken en kaart functie(s).
## Het vijfde deel bevat de downloadfuncties.
## ---------------------------------------------------------

function(input, output, session){ 
  
  ## Gedeelte 1 ----
  # Initialiseren kaart en reactieve datasets
    # Genereren onderliggende kaart voor de toolbox ----
  # Hierop staan de knmi-stations, de luchtmeetnetstations en de sensoren
  # Daarnaast zijn er edit buttons toegevoegd
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      setView(5.928729, 51.985103, zoom = 12) %>%
      addCircleMarkers(data = sensor_unique, ~lon, ~lat, layerId = ~kit_id, label = lapply(sensor_labels, HTML), 
                       radius = 8, color = ~kleur, fillOpacity = 1, stroke = ~selected, group = "sensoren")%>%
      addDrawToolbar(
        targetGroup = 'Selected',
        polylineOptions = FALSE,
        markerOptions = FALSE,
        polygonOptions = FALSE, 
        circleOptions = FALSE,
        rectangleOptions = drawRectangleOptions(shapeOptions=drawShapeOptions(fillOpacity = 0
                                                                              ,color = 'black'
                                                                              ,weight = 1.5)),
        editOptions = editToolbarOptions(edit = FALSE, selectedPathOptions = selectedPathOptions()))
  })
  
    # Reactieve datasets opzetten----
  values <- reactiveValues(df = sensor_unique, groepsnaam = geen_groep, actiegroep = FALSE, df_gem = data.frame()) 
  overzicht_shapes <- reactiveValues(add = 0, delete = 0) # nodig om selectie ongedaan te maken
  
  ## Gedeelte 2 ----
  # Functionaliteiten sensoren in de toolbox
    # Functie: Set the sensor as deselect and change color to base color ----
  set_sensor_deselect <- function(id_select){
    values$df[values$df$kit_id == id_select, "selected"] <- FALSE 
    values$df[values$df$kit_id == id_select, "kleur"] <- kleur_marker_sensor
    values$df[values$df$kit_id == id_select, "groep"] <- geen_groep
  }
  
    # Functie: Set sensor as select and specify color ----
  set_sensor_select <- function(id_select){
    values$df[values$df$kit_id == id_select, "selected"] <- TRUE 
    # Selecteer een kleur en geef dit mee aan de sensor
    # Kies de eerste kleur in de lijst kleur_cat die aanwezig is
    count  <- 1
    # Zorg ervoor dat je blijft zoeken tot sensor een kleur heeft of dat de kleuren op zijn
    while (kleur_sensor == "leeg" & count < length(kleur_cat)){
      for (kleur_code in kleur_cat){
        if (kleur_code %in% unique(values$df$kleur)){
          count <- count + 1
          next # Als de kleur al is toebedeeld, sla deze dan over
        }else{ 
          kleur_sensor <- kleur_code # Vrije kleur voor de sensor
        }
      }
    }
    # Als alle kleuren gebruikt zijn: kies zwart
    if (count == length(kleur_cat)){
      kleur_sensor <- "black"
    }
    
    # Bekijk of een sensor moet worden toegevoegd aan de groep
    if (values$actiegroep){
      # Als de groep al bestaat, zoek die kleur op
      if(values$groepsnaam %in% values$df$groep){
        kleur_sensor <- values$df[which(values$df$groep == values$groepsnaam),'kleur'][1]
      }
      # Geef aan dat de sensor bij die groep hoort. LET op: kan pas na opzoeken van de kleur van de groep
      values$df[values$df$kit_id == id_select, "groep"] <- values$groepsnaam
    }
    
    # Geef kleur aan de sensor
    values$df[values$df$kit_id == id_select, "kleur"] <- kleur_sensor
    kleur_sensor <- "leeg"
  }
  
    # Functie om de plaats van de sensoren met de juiste kleur op de kaart weer te geven ----
  add_sensors_map <- function(){ 
    # Regenerate the sensors for the markers
    sensor_loc <- unique(select(values$df, kit_id, lat, lon, kleur, selected))
    
    # Update map with new markers to show selected 
    proxy <- leafletProxy('map') # set up proxy map
    proxy %>% clearGroup("sensoren") # Clear sensor markers
    proxy %>% addCircleMarkers(data = sensor_loc, ~lon, ~lat, layerId = ~kit_id, label = lapply(as.list(sensor_loc$kit_id), HTML),
                               radius = 8, color = ~kleur, fillOpacity = 1,stroke = ~selected, group = "sensoren")}
  
    # Functie om van alle groepen in de dataset een gemiddelde te berekenen ----
  calc_groep_mean <- function(){
    # LET OP: wind moet via vectormean. Zie openair timeAverage
    gemiddeld_all <- data.frame()
    for(groepen in unique(values$df$groep)){
      if (groepen != geen_groep){
        # Haal de kit_ids van de sensoren in de groep op
        sensor_groep <- values$df[which(values$df$groep == groepen),'kit_id']
        # Zoek de gegevens van de groep op
        te_middelen <- input_df[which(input_df$kit_id %in% sensor_groep),]
        # Bereken het gemiddelde van de groep. LET OP; vector middeling
        gemiddeld <- timeAverage(te_middelen, avg.time='hour', vector.ws=TRUE)
        gemiddeld$kit_id <- groepen
        gemiddeld_all <- rbind(gemiddeld_all,gemiddeld)
      }} 
    # Maak de gemiddeld_all de reactive
    values$df_gem <- gemiddeld_all
  }
  
  ## Gedeelte 3 ----
  # Observatie functionaliteiten
  
    # Observeratie of er een groep gaat worden gebruikt ----
  observeEvent({input$A_groep},{
    if(input$A_groep){
      # Selectie van een groep. Sensoren krijgen groepsnaam en zelfde kleur
      values$groepsnaam <- input$Text_groep
      values$actiegroep <- TRUE
    }
    else{
      # Geen groep: dan losse selectie weer mogelijk
      values$groepsnaam <- geen_groep
      values$actiegroep <- FALSE
    }
  })     
  
    # Observeratie of de tekst wordt aangepast (de checkbox is dan aangeklikt) ----
  # Dan wil je dat er een nieuwe groep wordt aangemaakt
  # Bijvoorbeeld: je hebt een groep "Wijk aan Zee" aangemaakt, en je begint een nieuwe naam te typen "IJmuiden". 
  # Deze groep moet dan nieuw aangemaakt worden "IJmuiden".
  observeEvent({input$Text_groep},{
    if(values$actiegroep){
      values$groepsnaam <- input$Text_groep
    }
  })
  
    # Observeratie of de gebruiker een sensor selecteerd ----
  observeEvent({input$map_marker_click$id}, {
    id_select <- input$map_marker_click$id
    # Wanneer er op een Luchtmeetnet of KNMI station marker geklikt wordt, gebeurt er niks
    if (is_empty(grep("^knmi|^NL", id_select)) ){
      # Check if sensor id already selected -> unselect sensor
      if((values$df$selected[which(values$df$kit_id == id_select)][1])){
        set_sensor_deselect(id_select)
      }
      # If sensor is not yet present -> select sensor
      else{
        set_sensor_select(id_select)
      }
      # Laad de sensoren op de kaart zien
      add_sensors_map()
      # Bij elke selectie of deselectie moet de gemiddelde voor de groep herberekend worden
    }
  })
  
    # Observeratie of de selectie moet worden gereset ----
  # De values selected worden weer FALSE en de markers kleur_sensor_marker gekleurd, groepen verwijderd
  observeEvent(input$reset, {
    values$df[, "selected"] <- FALSE 
    values$df[, "kleur"] <- kleur_marker_sensor
    values$df[, "groep"] <- geen_groep
    # Laad de sensoren op de kaart zien
    add_sensors_map()
  })
  
    # Observeratie van een multiselectie ----
  observeEvent(input$map_draw_new_feature,{
    
    # Houd bij hoeveel features er zijn. Later nodig bij verwijderen, i.v.m. reset ook de losse selectie.
    overzicht_shapes$add <- overzicht_shapes$add + 1
    
    # Zoek de sensoren in de feature
    found_in_bounds <- findLocations(shape = input$map_draw_new_feature,
                                     location_coordinates = ms_coordinates,
                                     location_id_colname = "kit_id")
    # Ga elke sensor af en voeg deze bij de selectie
    for(id_select in found_in_bounds){
      # Wanneer er op een LML of KNMI station marker geklikt wordt, gebeurt er niks
      if (is_empty(grep("^knmi|^NL", id_select)) ){
        # Check if sensor id already selected -> unselect sensor
        if((values$df$selected[which(values$df$kit_id == id_select)][1])){
          set_sensor_deselect(id_select)
        }
        # If sensor is not yet present -> select sensor
        else{ 
          set_sensor_select(id_select)
        }
      }
      # Laad de sensoren op de kaart zien
      add_sensors_map()
    }
  })
  
  
    # Observeratie voor  deselecteren van een multiselectie ----
  # Er zijn namelijk twee manieren om sensoren te selecteren: d.m.v. los aangeklikte sensoren (1), en d.m.v.
  # de DrawToolBox (2). De delete knop op de DrawToolBox verwijderd enkel de sensoren die d.m.v. de DrawToolBox geselecteerd zijn,
  # dus niet de losse sensoren. Onderstaand stukzorgt ervoor dat zowel selectie via (1) als (2) worden verwijderd.
  
  observeEvent(input$map_draw_deleted_features,{
    # Aantal te verwijderen features
    overzicht_shapes$delete <- length(input$map_draw_deleted_features$features)
    # Check of alle features worden verwijderd. Als dat het geval is, zet dan alle markers ook op deselected
    # Dus ook degene die individueel zijn geklikt
    if(overzicht_shapes$delete == overzicht_shapes$add){
      values$df[, "selected"] <- FALSE 
      values$df[, "kleur"] <- kleur_marker_sensor
      values$df[, "groep"] <- geen_groep
    }
    else{
      # Als er maar één feature wordt verwijderd, ga dan de sensoren af en deselecteer deze een voor een
      for(feature in input$map_draw_deleted_features$features){
        bounded_layer_ids <- findLocations(shape = feature, location_coordinates = ms_coordinates, location_id_colname = "kit_id")
        for(id_select in bounded_layer_ids){
          # Wanneer er op een LML of KNMI station marker geklikt wordt, gebeurt er niks
          if (is_empty(grep("^knmi|^NL", id_select)) ){
            # Check if sensor id already selected -> unselect sensor
            if((values$df$selected[which(values$df$kit_id == id_select)][1])){
              set_sensor_deselect(id_select)
            }
          }
        }
      }
    }
    # Houd bij hoeveel shapes er nog zijn
    overzicht_shapes$add <- overzicht_shapes$add - overzicht_shapes$delete
    # Laat de sensoren op de kaart zien
    add_sensors_map()
  })
  
  ## Gedeelte 4 ----
  # Plots, grafieken en kaart functies
  
    # Creeren time plot (openair) ----
  output$timeplot <- renderPlot({
    
    comp <- selectReactiveComponent(input)
    dates <- selectReactiveDates(input)
    selected_id <- values$df[which(values$df$selected & values$df$groep == geen_groep),'kit_id']
    show_input <-input_df[which(input_df$kit_id %in% selected_id),]
    
    # Als er groepen zijn geselecteerd, bereken dan het gemiddelde
    if (length(unique(values$df$groep))>1){
      calc_groep_mean() # berekent groepsgemiddeldes
      show_input <- merge(show_input,values$df_gem, all = T) }
    
    # if / else statement om correctie gekalibreerde data toe te voegen ----
    if(comp == "pm10"){
      try(timePlot(selectByDate(mydata = show_input,start = dates()$start, end = dates()$end),
                   pollutant = c(comp, "pm10_kal"), wd = "wd", type = "kit_id", local.tz="Europe/Amsterdam"))
      # Call in try() zodat er geen foutmelding wordt getoond als er geen enkele sensor is aangeklikt 
    }
    if(comp == "pm25"){
      try(timePlot(selectByDate(mydata = show_input,start = dates()$start, end = dates()$end),
                   pollutant = c(comp, "pm25_kal"), wd = "wd", type = "kit_id", local.tz="Europe/Amsterdam"))
      # Call in try() zodat er geen foutmelding wordt getoond als er geen enkele sensor is aangeklikt 
    }
  })
  
    # Creeren kalender PM10 plot (openair) ----
  output$calendar1 <- renderPlot({
    
    comp <- selectReactiveComponent(input)
    dates <- selectReactiveDates(input)
    selected_id <- values$df[which(values$df$selected & values$df$groep == geen_groep),'kit_id']
    show_input <-input_df[which(input_df$kit_id %in% selected_id),]
    
    # Als er groepen zijn geselecteerd, bereken dan het gemiddelde
    if (length(unique(values$df$groep))>1){
      calc_groep_mean() # berekent groepsgemiddeldes
      show_input <- merge(show_input,values$df_gem, all = T) }
    
    try(calendarPlot(selectByDate(mydata = show_input, start = dates()$start, end = dates()$end),
                     pollutant = comp, limits= c(0,50), cols = 'Reds', local.tz="Europe/Amsterdam")) 
    # Call in try() zodat er geen foutmelding wordt getoond als er geen enkele sensor is aangeklikt 
  })

    # Creeren kalender PM2,5 plot (openair) ----
  output$calendar2 <- renderPlot({
    
    comp <- selectReactiveComponent(input)
    dates <- selectReactiveDates(input)
    selected_id <- values$df[which(values$df$selected & values$df$groep == geen_groep),'kit_id']
    show_input <-input_df[which(input_df$kit_id %in% selected_id),]
    
    # Als er groepen zijn geselecteerd, bereken dan het gemiddelde
    if (length(unique(values$df$groep))>1){
      calc_groep_mean() # berekent groepsgemiddeldes
      show_input <- merge(show_input,values$df_gem, all = T) }
    
    try(calendarPlot(selectByDate(mydata = show_input, start = dates()$start, end = dates()$end),
                     pollutant = comp, limits= c(0,25), cols = 'Reds', local.tz="Europe/Amsterdam")) 
    # Call in try() zodat er geen foutmelding wordt getoond als er geen enkele sensor is aangeklikt 
  })
  
    
    # Creeren timevariation functie (openair) ----
  output$timevariation <- renderPlot({
    
    comp <- selectReactiveComponent(input)
    dates <- selectReactiveDates(input)
    selected_id <- values$df[which(values$df$selected & values$df$groep == geen_groep),'kit_id']
    show_input <-input_df[which(input_df$kit_id %in% selected_id),]
    
    # Als er groepen zijn geselecteerd, bereken dan het gemiddelde
    if (length(unique(values$df$groep))>1){
      calc_groep_mean() # berekent groepsgemiddeldes
      show_input <- merge(show_input,values$df_gem, all = T) }
    
    ## Create array for the colours
    # get the unique kit_id and the color
    kit_kleur <- unique(values$df[which(values$df$selected),c('kit_id','kleur','groep')])
    
    # Als er een groep is, zorg voor 1 rij van de groep, zodat er maar 1 kleur is
    if (length(unique(kit_kleur$groep)>1)){
      kit_kleur[which(kit_kleur$groep != geen_groep),'kit_id'] <- kit_kleur[which(kit_kleur$groep != geen_groep),'groep']
      kit_kleur <- unique(kit_kleur)
    }
    
    # Sort by kit_id
    kit_kleur_sort <- kit_kleur[order(kit_kleur$kit_id),]
    # create colour array
    kleur_array <- kit_kleur_sort$kleur
    
    try(timeVariation(selectByDate(mydata = show_input, start = dates()$start, end = dates()$end),
                      pollutant = comp, normalise = FALSE, group = "kit_id",
                      alpha = 0.1, cols = kleur_array, local.tz="Europe/Amsterdam",
                      ylim = c(0,NA))) 
    # Call in try() zodat er geen foutmelding wordt getoond als er geen enkele sensor is aangeklikt 
    
  })
  
    # Creeren interactive graphic PM10 (plotly) ----
  
  output$interplot <- renderPlotly({
    
    comp <- selectReactiveComponent(input)
    dates <- selectReactiveDates(input)
    selected_id <- values$df[which(values$df$selected & values$df$groep == geen_groep),'kit_id']
    show_input <-input_df[which(input_df$kit_id %in% selected_id),]
    
    q <- ggplot(show_input, aes(x=date, y=pm10, color=kit_id))
    q <- q + geom_line()
    q <- q + geom_point(size=1)
    q <- q + scale_colour_hue(name="Legenda", l=20)
    q <- q + xlab("Datum") + ylab("pm 10")
    q <- q + ggtitle("PM 10 waarde in een bepaald tijdsbestek")
    q <- q + theme_bw()
    
  })
    # Creeren interactive graphic PM2,5 (plotly) ----
  
  output$interplot_n <- renderPlotly({
    
    comp <- selectReactiveComponent(input)
    dates <- selectReactiveDates(input)
    selected_id <- values$df[which(values$df$selected & values$df$groep == geen_groep),'kit_id']
    show_input <-input_df[which(input_df$kit_id %in% selected_id),]
    
    q <- ggplot(show_input, aes(x=date, y=pm25, color=kit_id))
    q <- q + geom_line()
    q <- q + geom_point(size=1)
    q <- q + scale_colour_hue(name="Legenda", l=40)
    q <- q + xlab("Datum") + ylab("pm 2,5")
    q <- q + ggtitle("PM 2,5 waarde in een bepaald tijdsbestek")
    q <- q + theme_bw()
  
  }) 
  
    # Creeren overzicht tabel Samen Meten----
  
  output$table_overviewSam <- renderDT(input_df,
                           filter = "top",
                           options = list(
                             pageLength = 10
                           )
  )
  
    # Creeren overzicht tabel Samen Meten----
  
  output$table_overviewLuft <- renderDT(API_Luftdaten,
                                    filter = "top",
                                    options = list(
                                      pageLength = 10
                                    )
  )
  
    # Creeren grote kaart ----
  
  # Met de onderstaande codes worden de twee datastromen (pm10/pm2.5) voor de slider uitgewerkt
  # Met de functie reactive wordt er aangegeven dat de data moet mee veranderen met de instellingen van de slider
  sliderData1 <- reactive({
    API_Luftdaten[API_Luftdaten$P1 >= input$range[1] & API_Luftdaten$P1 <= input$range[2] ,]
  })
  
  sliderData2 <- reactive({
    API_Luftdaten[API_Luftdaten$P2 >= input$range[1] & API_Luftdaten$P2 <= input$range[2] ,]
  })
  
  
  # Met de onderstaande code wordt een kleurenschema aangemaakt
  bins <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, Inf)
  color_gradient <- colorBin("YlOrRd", domain = API_Luftdaten$P1, bins = bins)
  
  
  #In de onderstaande code wordt de opmaak van de titel vormgegeven
  
  tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    position: fixed !important;
    left: 50%;
    text-align: center;
    padding-left: 15px; 
    padding-right: 15px; 
    background: rgba(255,255,255,0.75);
    font-weight: bold;
    font-size: 28px;
  }
"))
  
  # In de onderstaande code krijgt de titel een naam 
  title <- tags$div(
    tag.map.title, HTML("Realtime DataViewer (Luftdaten API) ")
  )  
  
  
  # Met behulp van de onderstaande code wordt de kaart vormgegeven (renderLeaflet/leaflet)
  # Deze kaart bevat geen (dynamische) data uit de API. Deze data wordt in de functie ProxyLeafet
  # binnengehaald en gelinkt aan deze kaart. Binnen deze code worden alle functies uitgewerkt
  # die binnen de kaart tot de beschikking zijn
  output$MyMap <- renderLeaflet({
    leaflet(API_Luftdaten) %>% 
      
      # In de onderstaande code wordt de titel aan de kaart toegevoegd
      addControl(title, position = "topleft", className="map-title")%>%
      
      
      # Met de onderstaande code worden verschillende basemaps ingeladen 
      addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Satelliet") %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Gray Canvas") %>%
      
      
      # Met de onderstaande code wordt de standaard basemap ingesteld (OpenStreetMap)
      addTiles(group = "OpenStreetMap") %>% 
      
      # Met deze code wordt het standaard kaartscherm ingesteld (gemeente Arnhem)
      setView(5.906991, 51.981582, zoom = 12) %>% 
      
      # Met de onderstaande codes wordt het selectievakje gemaakt 
      # Met behulp van dit selectievakje is het mogelijk om een meetwaarde te selecteren (pm10 & pm25)
      # Hiernaast is het mogelijk om een basemap toe te voegen
      addLayersControl(
        baseGroups = c("OpenStreetMap", "Satelliet", "Gray Canvas"),
        overlayGroups = c("pm10", "pm2.5"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      
      # Met de onderstaande code wordt het selectievakje pm2.5 
      # standaard uitgezet
      hideGroup("pm2.5") %>%
      
      
      # Met de onderstaande codes wordt de minimap gemaakt 
      addMiniMap(toggleDisplay = TRUE) %>%
      
      
      # Met de onderstaande code wordt een legenda toegevoegd 
      addLegend("bottomleft", pal =  color_gradient, values = API_Luftdaten$P1,
                title = "Meetwaardes (μg/m3)") %>%
      
      
      # Met de onderstaande code wordt een knop toegevoegd (Javascript)
      # Hiermee is het mogelijk om automatisch te in/uit te zoomen naar Nederland
      addEasyButton(easyButton(
        icon="fa-globe", title="Zoom naar Nederland",
        onClick=JS("function(btn, map){ map.setZoom(7); }"))) %>%
      
      
      # Met de onderstaande code wordt een knop toegevoegd (Javascript)
      # Hiermee is het mogelijk om in te zoomen naar je locatie
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Mijn Locatie",
        onClick=JS("function(btn, map){ map.locate({setView: true, enableHighAccuracy: true}); }")))%>%
      
      
      # Met de onderstaande code wordt een schaalbalk toegevoegd
      addScaleBar(position = "bottomleft", options = scaleBarOptions(metric = TRUE, 
                                                                     imperial = FALSE, maxWidth = 150))%>%
      
      
      # Met de onderstaande code wordt een reset knop toegevoegd
      addResetMapButton()%>%
      
      
      # Met de onderstaande code wordt een zoekfunctie toegevoegd 
      # Hiermee is het mogelijk om naar plaatsnamen te zoeken
      addSearchOSM(options = searchOptions(moveToLocation = TRUE, 
                                           collapsed = TRUE, autoCollapse = FALSE,textCancel = "Verwijderen", 
                                           zoom = 15, autoType = TRUE, autoResize = TRUE, 
                                           hideMarkerOnCollapse = TRUE, textErr = "Locatie niet gevonden", 
                                           textPlaceholder = "Zoeken..."))
  })
  
  
  
  # Met de onderstaande code wordt de (dynamische) data vormgegeven en gelinkt aan de kaart (en functies) 
  # die hierboven is gemaakt. Hiervoor wordt de functie leafletProxy gebruikt. Deze functie
  # kan met dynamische data werken en doordat de data veranderd dient te worden met de slider
  # moet de data binnengehaald worden met deze functie. De Observe functie geeft aan dat de data moet 
  # kunnen reageren op veranderingen (slider)
  
  observe({
    leafletProxy("MyMap", data = sliderData1()) %>%
      clearMarkers() %>%  
      
      
      # Met de onderstaande codes worden cirkels in de kaart getekend voor de waarde P1 (pm10)
      # Deze waardes worden gelinkt aan de slider 
      # Ook wordt er een label aangekoppeld en en verwezen naar het gemaakte kleurenschema (color_gradient)
      # Ook wordt er verwezen naar het selectievakje en worden de klusterfunctie toegepast (klusteren van cirkels)
      # Tot slot wordt er een zwarte lijn om de cirkel getekend
      addCircleMarkers(data = sliderData1(), ~lon, ~lat, layerId = ~kit_id, 
                       label = lapply(sliderData1()$P1, HTML), radius = 8, 
                       fillColor = color_gradient(sliderData1()$P1), fillOpacity = 1, 
                       group = "pm10", stroke = TRUE, color = "black", weight = 2,
                       
                       # Met de onderstaande code wordt het pop up scherm vormgegeven
                       popup= ~paste("Sensor ID:", sliderData1()$sensor.id, "<br>",
                                     "Meetwaarde:", "pm10", "<br>",
                                     "Sensorwaarde:", sliderData1()$P1, "<br>",
                                     "Coordinaten:", sliderData1()$lat,",  ", sliderData1()$lon))%>%
      
      
      # Met de onderstaande codes worden cirkels in de kaart getekend voor de waarde P2 (pm2.5)
      # Deze waardes worden gelinkt aan de slider 
      # Hiernaast wordt er een label aangekoppeld en en verwezen naar het gemaakte kleurenschema (color_gradient)
      # Ook wordt er verwezen naar het selectievakje en worden de klusterfunctie toegepast (klusteren van cirkels)
      # Tot slot wordt er een zwarte lijn om de cirkel getekend
      addCircleMarkers(data = sliderData2(),~lon, ~lat, layerId = ~sensor.id, 
                       label = lapply(sliderData2()$P2, HTML), radius = 8, 
                       fillColor = color_gradient(sliderData2()$P2), fillOpacity = 1, 
                       group = "pm2.5", stroke = TRUE, color = "black", weight = 2, 
                       
                       # Met de onderstaande code wordt het pop up scherm vormgegeven
                       popup= ~paste("Sensor ID:", sliderData2()$sensor.id, "<br>",
                                     "Meetwaarde:", "pm2.5", "<br>",
                                     "Sensorwaarde:", sliderData2()$P2, "<br>",
                                     "Coordinaten:", sliderData2()$lat,",  ", sliderData2()$lon))
  })

  ## Gedeelte 5 ----
  # Download functies 

    # Creeren download functie voor de de sensoren in de toolbox (downloadtabblad) ----
  datasetInput <- reactive({
    # Wanneer de gebruiker een sensor id selecteert, wordt de juiste dataset gegeven.
    switch(input$dataset,
           "LTD_22481" = input_df1,
           "LTD_24283" = input_df2,
           "LTD_24322" = input_df3,
           "LTD_24801" = input_df4,
           "LTD_25494" = input_df5,
           "LTD_27239" = input_df6,
           "LTD_27720" = input_df7,
           "LTD_31298" = input_df8)
  })

  fileext <- reactive({
    switch(input$type,
    # Wanneer de gebruiker een bestandsformaat selecteert, wordt het juiste formaat gegeven.
           "Excel (CSV)" = "csv", "Text (TSV)" = "txt", "Text (Space Seperated)" = "txt", "Doc" = "doc")
  })
  
  output$downloadData <- downloadHandler(
    filename = function(){
      # Zorgt ervoor dat de 
      paste(input$dataset, fileext(), sep=".")
    },
    
    content = function(file) {
      sep <- switch(input$type, "Excel (CSV)" = ",", "Text (TSV)" = "\t", "Text (Space Separated)" = " ", "Doc" = " ")
      
      write.table(datasetInput(), file, sep = sep,
                  row.names = FALSE)
    }
  )
    # Creeren download functies voor de plotten in de toolbox (test) ----
  
  output$downloadTimePlot <- downloadHandler(
    filename = function(){ 
      paste('.png', sep='') },
    content = function(file) {
      ggsave(file,timeplot())
      
    })
}
