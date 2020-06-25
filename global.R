## ---------------------------------------------------------
## R Script voor interactieve data-analyse van sensordata, met o.a. packages zoals 'shiny', 'leaflet' en 'openair'.     
## Dit platform bestaat uit meerdere scripts. Dit is het global.R script.
## Auteurs: 
## (Fundatie platform) Henri de Ruiter en Elma Tenner namens het Samen Meten Team, RIVM. 
## (Uitbreiding platform) Thomas Geurts van Kessel en Stefan Knoet namens de HAS en Radboud Universiteit 
## Laatste versie: juni 2020
## ---------------------------------------------------------
## Opmerkingen: 
## (In dit script wordt er een titel toegewezen aan het platform.)
## Het eerste deel bevat de pakketten die nodig zijn voor het platform.
## Het tweede deel bevat het inladen van de desbetreffende datasets van de API's.
## Het derde deel bevat het inladen van de reactieve onderdelen.
## Het vierde deel bevat originele codes voor de stijling van sensoren.
## ---------------------------------------------------------

## Titel platform ---- 
projectnaam <- "Burger Sensor Data platform"

## Gedeelte 1 ----
# Benodigde pakketten installeren en activeren.

# Installeren: 'install.packages()'
# Activeren: 'library()'s
library(openair)
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(shinythemes)
library(shinyWidgets)
library(purrr)
library(sp)
library(devtools)
library(geoshaper)
library(shiny)
library(dplyr)
library(jsonlite)
library(tidyr)
library(plyr)
library(ggplot2)
library(plotly)
library(markdown)
library(DT)

## Gedeelte 2 ----
# Inladen RDS bestanden API's; Samen Meten en Luftdaten.

# API Samen Meten.
file1 <- "LTD_22481.rds" 
file2 <- "LTD_24283.rds"
file3 <- "LTD_24322.rds"
file4 <- "LTD_24801.rds"
file5 <- "LTD_25494.rds"
file6 <- "LTD_27239.rds"
file7 <- "LTD_27720.rds"
file8 <- "LTD_31298.rds"
# API Luftdaten.
file9 <- "API_Luftdaten.rds"

# RDS bestanden omzetten naar datasets.

# API Samen Meten.
input_df1 <- readRDS(file1)
input_df2 <- readRDS(file2)
input_df3 <- readRDS(file3)
input_df4 <- readRDS(file4)
input_df5 <- readRDS(file5)
input_df6 <- readRDS(file6)
input_df7 <- readRDS(file7)
input_df8 <- readRDS(file8)
# API Luftdaten.
API_Luftdaten <- readRDS(file9)

# Samenvoegen Samen Meten API datasets.
input_df <-  rbind.fill(input_df1,input_df2,input_df3,input_df4,input_df5,input_df6,input_df7,input_df8)

## Gedeelte 3 ----
# Inladen reactieve onderdelen.

# Functies voor het genereren van de input opties voor openair call.
source("selectReactiveComponent.R", local = TRUE) 
# Functies voor het genereren van de inhoud van de tabpanels.
source("tabPanels.R", local = TRUE) 

## Gedeelte 4 ----

choices <- c( "PM10 - gekalibreerd", "PM2.5 - gekalibreerd","PM10", "PM2.5") #set up choices for shiny app
kleur_cat <- list('#42145f','#ffb612','#a90061','#777c00','#007bc7','#673327','#e17000','#39870c', '#94710a','#01689b','#f9e11e','#76d2b6','#d52b1e','#8fcae7','#ca005d','#275937','#f092cd')
kleur_sensor <- "leeg"
kleur_marker_sensor <- "#525252" # default kleur sensor
geen_groep <- "" # default waarde als de sensor niet in een groep zit

icons_stations <- iconList(
  knmi = makeIcon("ionicons_compass.svg", 18, 18),
  lml = makeIcon("ionicons_analytics.svg", 15, 15))

# Default locatie, kleur en label opzetten 
input_df$kit_id <- gsub('HLL_hl_', '', input_df$kit_id) #remove HLL-string from input_df for shorter label

# Voor de sensormarkers: locatie, label en kleur etc. Per sensor één unieke locatie
sensor_unique <- aggregate(input_df[,c('lat','lon')], list(input_df$kit_id), FUN = mean) # gemiddelde om per sensor een latlon te krijgen
names(sensor_unique)[names(sensor_unique)=='Group.1'] <-'kit_id'
sensor_unique$selected <-FALSE
sensor_unique$groep <- geen_groep
sensor_unique$kleur <- kleur_marker_sensor
sensor_labels <- as.list(sensor_unique$kit_id) # labels to use for hoover info

# Voor de multiselect tool: omzetten lat/lon naar spatialpoints
ms_coordinates <- SpatialPointsDataFrame(sensor_unique[,c('lon','lat')],sensor_unique)

# Voor de knmimarkers: locatie en labels opzetten
knmi_stations <- data.frame("code" = c("knmi_06225", "knmi_06240", "knmi_06260"), "lat" =c(52.4622,52.3156,52.0989), "lon" =c(4.555,4.79028,5.17972))
knmi_stations$naam <- c("IJmuiden", "Schiphol", "De Bilt")
knmi_labels <- as.list(paste("KNMI", knmi_stations$naam, sep = ": "))

# Voor de lmlmarkers: locatie en labels opzetten
lml_stations <- data.frame("code" = c("NL49014","NL49551","NL49572","NL49561","NL10636","NL49573","NL49570","NL49553","NL49012"))
lml_stations$lat <- c(52.3597,52.463,52.4744,52.334,52.105,52.4789,52.4893,52.494,52.39)
lml_stations$lon <- c(4.86621,4.60184,4.6288,4.77401,5.12446,4.57934,4.64053,4.60199,4.88781)

# Maak in de labelling onderscheid tussen de LML en GGD stations
lml_labels <- vector("list", length(lml_stations$code))
lml_labels[grep('NL49', lml_stations$code)] <- "GGD"
lml_labels[grep('NL10', lml_stations$code)] <- "LML"
lml_labels <- as.list(paste(lml_labels, lml_stations$code, sep = ": "))
