Inhoudsopgave
-------------

-   [Achtergrond](#achtergrond)
-   [Documentatie](#documentatie-Burger-Sensor-Data-Platform)

Achtergrond
===========

Introductie
-----------

Steeds meer burgers, bedrijven en overheden meten de luchtkwaliteit met
sensoren. Er vind een toename plaats van mensen die graag inzage willen krijgen
in de kwaliteit van de lucht in hun nabije omgeving. Om mensen inzage te geven in de luchtkwaliteit
is er een sensor data platform ontwikkeld, namelijk: 'Het Burger Sensor Data Platform".
Om bij het platform te komen kunt u op de volgende link klikken: [Het Burger Sensor Data Platform](https://stefansapplications.shinyapps.io/Burger-Sensor-Data-Platform/).
Als basis voor het platform en met goedkeuring van het RIVM zij de R-script van het Hollandse Luchten platform gebruikt.
Dit platform is evenals ontwikkeld voor het inzichtelijk maken van sensordata. Informatie over het platform
kunt u vinden in de volgende link: [Hollandse Luchten platform](https://rivm.shinyapps.io/app_HLL/).

Op het Burger Sensor Data Platform kunnen gemeten sensorwaarden bekeken en gevisualiseerd worden.
Het platform bevat twee ingeroepen API's die voor verschillend doeleinden zijn gebruikt.
Hierdoor kan er in het platform gespeelt worden met verschillende functionaliteiten.
Het is van belang om als burger, die wilt weten wat de huidige stand van zaken 
van de luchtkwaliteit, antwoord te krijgen op de vraag of het goed of slecht is. Om antwoord te krijgen is het van belang
dat er bepaalde analyses uitgevoerd kunnen worden. De Burger Sensor Data Platform is  hiervoor ontwikkeld:
een interactief platform voor visualisatie en analyse van sensordata. Het gaat hierbij zowel om het bekijken van real-time- en
historische data (5 dagen). 

Het huidige platform is een prototype en zit nog vol in de ontwikkeling. Hierdoor kunnen er functies worden
aangepast of toegevoegd.  

Opensource
----------

Het platform is opensource, zodat alle bestanden rondom het platform voor iedereen beschikbaar 
worden gesteld. Iedereen is welkom om het platform te gebruiken en ook om elementen in het 
platform aan te passen. (volgens de [GPL v3])

Iedereen is welkom om de tool te gebruiken en
aan te passen (volgens de [GPL v3](https://www.gnu.org/licenses/gpl-3.0.en.html) licentie). Hieronder volgt een
beschrijving van de hoofdelementen van het platform. 
Meldingen van errors of opmerkingen over de code graag via een *Issue*
op GitHub zelf, je moet daarvoor wel inloggen op GitHub.

Documentatie 
============

Inhoudsopgave
-------------

-   [Kennis vooraf](#kennis-vooraf)
-   [Run het platform](#run-het-platform)
-   [Opbouw en structuur](#opbouw-en-structuur)
-   [Input data](#input-data)
-   [global.R](#globalr)
-   [ui.R en server.R](#uir-en-serverr)
-   [ui.R](#uir)
-   [server.R](#serverr)
    -   [Het maken van de kaarten](#het-maken-van-de-kaarten)
    -   [Het maken van de grafieken](#het-maken-van-de-grafieken)
    -   [Het opzetten van een interactief dataframe](#het-opzetten-van-een-interactief-dataframe)
    -   [Overzicht van de functies](#overzicht-van-de-functies)
    -   [Overzicht van de ObserveEvents](#overzicht-van-de-observeevents)
-   [Nawoord](#nawoord)

Kennis vooraf
-------------

De scripts staan op GitHub.
[GitHub](https://guides.github.com/activities/hello-world/) is een zeer
geschikt platform om software te delen en met verschillende partijen te
ontwikkelen. Als u een account heeft, kunt u ook bijdragen aan het platform.
Gebruik hiervoor bijvoorbeeld ‘fork’ en ‘Pull request’, meer info vind je in de
[handleiding](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
van GitHub. Het is ook mogelijk om de hele map, met alle bijhorende bestanden,
te downloaden. Wanneer u een account heeft, kunt u ook bugs of verbeteringen melden via
de 'Issues'.  

Het platform is ontwikkeld met de programmeertaal
[R](https://www.r-project.org/). Voor het gebruik van het platform via de
interface ([hier](https://stefansapplications.shinyapps.io/Burger-Sensor-Data-Platform/))
is geen verstand van R nodig. Maar gezien u hier al bent, wilt u
waarschijnlijk zelf aan de slag. Meer informatie over programmeren in R
en het downloaden van RStudio kunt u vinden op de [website van RStudio](https://rstudio.com/).

Het is een interactief platform. De interactie wordt gegenereerd via de package 'Shiny'.
[Shiny](https://shiny.rstudio.com/) is een package in R waarmee dergelijke applicaties 
ontwikkeld kunnen worden. Enkele functies zullen toegelicht worden:

Voor het maken van de kaarten en de markers op de desbetreffende kaarten is de package
'leaflet' gebruikt. Een handleiding met uitgebreide uitleg is online te vinden is in 
de volgende link te vinden: ([leaflet](https://rstudio.github.io/leaflet/)).

In het platform bevinden zich meerdere visualisaties en grafieken. Deze
worden gemaakt via onder andere de package
[OpenAir](http://davidcarslaw.github.io/openair/). OpenAir is speciaal
ontwikkeld voor het onderzoeken naar luchtkwaliteit. Het toevoegen van
andere visualisaties is relatief simpel. Voor alle opties, voorbeelden
en uitleg kijk [hier](https://davidcarslaw.com/files/openairmanual.pdf).

Run het platform
-----------

Laten we eerst het huidige platform op uw eigen pc draaien. Start daarvoor
RStudio, maak een nieuw project aan en zet daar alle bestanden van
de GitHub repository in. De bestanden kunnen ook gedownload worden (zie hiervoor
de groene 'Clone'-knop). Als u hier op drukt verschijnt ook de optie om de bestanden
te downloaden. Wanneer u ervaring heeft met Git, kunt u ook een clone maken.

Voor het platform zijn een aantal packages nodig, waaronder
openair, leaflet, leaflet.extras, dplyr, shinythemes, shinyWidgets,
purrr, sp, devtools, ggplot2 en plotly.  Deze packages kunt u installeren via
de 'package manager' van RStudio of via het `install.packages`
commando. Naast deze packages heeft u ook de geoshaper package nodig,
deze moet u via GitHub installeren.  Het pakket kunt u vinden in de
[RedOakStrategic/geoshaper](https://github.com/RedOakStrategic/geoshaper)
repository. Installeren doet u met de volgende R commando's:

```
library(devtools)
install_github("RedOakStrategic/geoshaper")
```

Open als eerste het script global.R. Rechtsboven bevindt zich een groene driekhoek
met de tekst ‘Run app’. Als u hierop klikt komt het platform tevoorschijn. U heeft nu 
het platform werkend gekregen.

Hieronder volgt een beschrijving van de verschillende onderdelen van het platform. Er worden enkele
stappen en functies nader behandeld. Aan het eind heeft u een duidelijk inzicht
gekregen in de opbouw en de gebruikte functionaliteiten van het platform.

Opbouw en structuur
-------------------

Het platform bestaat uit vier hoofdgedeeltes:

1.   input data
2.   global.R
3.   server.R
4.   ui.R

### Input data

De data die in het platform gebruikt wordt, is uit twee API's opgeroepen:
De Samen Meten API en de Luftdaten API. Na het oproepen, ordenen en bewerken van de data,
zien de dataframes er als volgt uit:

De dataframe van de Samen Meten API ziet er als volgt uit:
kolomnaam | beschrijving  
--- | --- 
"date" | de datum en het begin-uur van het uurgemiddelde (Etc/GMT-1)
"kit\_id" | de naam van de sensor
"properties.owner" | de originaliteit van de sensor 
"value.encodingType" | de soort API 
"lat" | de latitude van de sensorlocatie 
"lon" | de longitude van de sensorlocatie 
"pm25" | de sensorwaarde voor PM2.5 waardes
"description.pm25" | de bijhorende omschrijving van PM2,5
"pm10" | de sensorwaarde voor PM10 waardes
"description.pm10" | de bijhorende omschrijving van PM10 
"pm25\_kal" | de gekalibreerde sensorwaarde voor PM2.5 waardes
"description.pm25.kal" | de bijhorende omschrijving van de gekalibreerde PM2,5 waardes
"pm10\_kal" | de gekalibreerde sensorwaarde voor PM10 waardes
"description.pm10.kal" | de bijhorende omschrijving van de gekalibreerde PM10 waardes

De dataframe van de Luftdaten API ziet er als volgt uit:
kolomnaam | beschrijving  
--- | --- 
"date" | de datum en het begin-uur van het uurgemiddelde (Etc/GMT-1)
"kit\_id" | de naam van de sensor
"lat" | de latitude van de sensorlocatie 
"lon" | de longitude van de sensorlocatie 
"location.country" | land waarin de sensor gepositioneerd is
"sensor.id" | unieke identificatie per geregistreerde waarde
"sensor.sensor_type.name" | het type sensor
"P1" | de sensorwaarde voor PM10  
"P2" | de sensorwaarde voor PM2.5 

Data uit de Samen Meten API bevat historische data (5 dagen) en data uit de Luftdaten API bevat real-time data.
Om de data up to date te houden is het van belang om de desbetreffende API scripts opnieuw in te roepen.
Tip voor de uitvoering: run voor de Samen Meten API alle scripts los, hierdoor worden alle rds bestandsformaten 
in het desbetreffende map geplaatst. Als alle rds bestanden eenmaal klaar zijn, kunt u deze kopieëren en plakken 
in de map met platform scripts (anders wordt de data niet ingeladen). Hetzelfde kan gedaan worden voor de Luftdaten API.

### global.R

Hierin staat de initialisatie van het platform, alle benodigdheden worden
geladen. In dit geval de bijhorende: **packages, functies, symbolen en de data.** De
functies die worden geladen zijn specifiek voor dit platform en staan in
een apart R-script.

Er zijn daarnaast een aantal initialisaties toegevoegd, zoals de gebruikte kleuren,
de naamgeving en de labels.

### ui.R en server.R

De ui en de server zijn als een boekenkast en boeken. Om een bibliotheek
te hebben, is er een boekenkast (de structuur) en boeken (de inhoud)
nodig. Zo kunt u het ook zien bij het platform: de ui is de boekenkast en
de server representeert de boeken. De connectie tussen de server en de ui 
gaat via unieke labels. Net zoals in een boekenkast van de bibliotheek. 

### ui.R

Hierin wordt dus het **frame** (de boekenkast) van het platform gemaakt: 
de tabbladen worden gedefinieerd, de positie van de kaart gemaakt etc.
Het script begint met de opmaak. In de eerste regels wordt een html-template
opgehaald.

Vervolgens is de pagina opgebouwd uit vier tabbladen die elk een eigen functies 
bevatten. De tabbladen zijn als volgt: toolbox, kaart, tabel Samen Meten en
tabel Luftdaten (het over ons tabblad wordt buiten beschouwing gelaten).

De **toolbox** bestaat uit een twee delen: **de sidebar en het mainpanel**.
De sidebar bestaat uit een leaflet-kaart en een menu met de bijhorende reactieve
componenten en de tijdsbalk. De mainpanel is verder onderverdeeld in tabbladen. 
Deze tabbladen zijn verwerkt in het script *tabPanels.R*. Elke tab heeft een eigen titel,
toelichting en soort output (plot, grafiek etc.)

De **kaart** omvat de gehele pagina. In de kaart bevinden zich een aantal functies.
Deze functies maken het mogelijk om binnen de kaart zowel te navigeren als te spelen
met de visualisaties in de kaart. 

De *tabel Samen Meten* geeft de datawaarden weer die in het platform zijn gebruikt.
Functies die de tabel bevat maakt het mogelijk om gemakkelijk bijvoorbeeld op een specifieke
sensor te filteren. Alle functionaliteiten zijn ook verwerkt in de *tabel Luftdaten*.

### server.R

De server genereert **de inhoud** van het platform. Hierin vind je **alle
functionaliteiten**: de markers kleuren, een selectie maken, de grafiek of plot
tonen, de kaart visualiseren etc.

Hier volgen eerst een aantal begrippen, die veel voorkomen in de code.

-   Voor alles wat als output/visualisatie in het platform komt, heeft het
    woord ‘output’. Bijvoorbeeld de kaart: **output$map**

-   De data wilt u interactief kunnen selecteren, hiervoor is er een
    interactief dataframe nodig. Dat kan via
    **‘reactiveValues(df=dataframe)’**.

-   Met de keuzes zoals ‘kies component’ wilt u direct de waardes zien
    veranderen. Dit soort directe interacties worden bijgehouden in een
    **‘observeEvent’**. Ook het selecteren van de sensoren gaat hiermee.

-   Voor het genereren van visualisaties of de kaart gebruik je
    ‘render’; **renderPlot voor grafieken en renderLeaflet voor de
    kaart**. Deze visualisaties of kaart zijn dan in *‘output$naamplot’*
    neergezet.

#### Het maken van de kaart

De kaarten in het platform worden gemaakt met behulp van
[leaflet](https://rstudio.github.io/leaflet/). Bij het opstarten van het
platform wordt de kaart, in de toolbox, volledig aangemaakt:

-   Geef aan dat u leaflet wilt gebruiken. Met ‘addTiles()’ wordt
    automatisch een **openstreetmap achtergrond** geladen
-   Stel het zoomniveau in 'setview'
-   Voeg de edit- en zoombuttons toe

Verdere aanpassingen aan de kaart, bijvoorbeeld kleurverandering van de
sensoren na het selecteren, gebeurt via de functie
*‘add\_sensors\_map’*. Deze functie werkt alsvolgt:

-   Maakt een **proxymap** aan. Deze komt als het ware over de huidige kaart
    heen
-   Verwijdert alle sensoren die er nu op staan
-   Zet de sensoren er weer op. De karakteristieken van de sensoren (de
    kleur) is in de data aangepast. Wanneer u de sensoren er weer
    opzet, hebben ze de nieuwe kleur.

#### Het maken van de grafieken

Voor de **visualisatie plots** maken we gebruik van het package
[OpenAir](http://davidcarslaw.github.io/openair/). De verschillende
grafieken gaan via hetzelfde structuur:

-   Bekijk welk **component** er gevisualiseerd moet worden
-   Bekijk in welke **tijdsperiode**
-   Ga na welke sensoren er **geselecteerd** zijn
-   Als er groepen zijn gedefinieerd, bereken daarvoor het
    **groepsgemiddelde**
-   Maak de grafiek via de **functie van openair**

Voor de **visualisatie grafieken** wordt er gebruik gemaakt van de package 
[Plotly](http://github.com/plotly). De interactieve grafieken gaan via
hetzelfde structuur:

-   Selecteren van een sensor.S
-   Afhankelijk van de grafiek wordt er automatisch een component geselecteerd.
-   Selecteer meerdere sensoren en speel hierbij met de functionaliteiten
    waarover de grafiek beschikt.

#### Het opzetten van een interactief dataframe

Het dataframe is niet een normaal dataframe, maar een interactief
dataframe. Dat houdt in dat je **interactief aanpassingen** kunt maken
in het dataframe; bijvoorbeeld het aanpassen van de kleur van de sensor.
In het dataframe is kleur een attribute. Deze kan worden gewijzigd door
de *selectfunctie* en meteen door de *add\_sensors\_map*-functie op de
kaart worden getoond.

In het interactieve dataframe (het heeft **de naam ‘values’**) zijn
verschillende kolommen:

-   df: het dataframe met de **eigenschappen van de sensoren** en de
    meetwaardes erin
-   groepsnaam: de waarde die de gebruiker heeft ingetypt voor de naam
    van de **groep**
-   actiegroep: boolean of is aangevinkt dat de sensor bij de groep
    hoort (True/False)
-   df\_gem: het dataframe met de **gemiddeldes per groep** erin

Het df is het **input dataframe**, dat wordt vanuit een .RDS bestand
ingeladen in **global.R**. Het bestaat uit verschillende
basiseigenschappen zoals de meetwaardes en locatie. Nadat het in
global.R is ingeladen, wordt het in **server.R** in een **interactief
dataframe** gezet.

De volledige **kolomnamen** zijn: "date", "kit\_id", "lat", "lon",
"pm10", "pm10\_kal", "pm25", "pm25\_kal", "wd", "ws", "rh", "temp",
"pm25\_lml", "pm10\_lml", "knmi\_id", "lml\_id",  "lml\_id\_pm25"

Daarnaast zijn er later in de tool nog een aantal eigenschappen per
sensor toegevoegd.

-   Selected: geeft aan of de sensor geselecteerd is (TRUE/FALSE)
-   Kleur: geeft de kleur van de sensor aan
-   Groep: geeft de groepsnaam aan. Wanneer niet in een groep is deze
    leeg: “”

#### Overzicht van de functies

Er zijn verschillende functies gemaakt voor de functionaliteiten van het
platform. Enkele functies konden in eigen R-scripts worden gezet en zijn
in global.R ingeladen. Andere functies zijn direct in server.R
gedefineerd, omdat die directe aanpassingen maken in het interactieve
dataframe. Van deze functies volgt hier een korte functie-omschrijving
om een inzicht te geven in de structuur.

*set\_sensor\_deselect* – functie om de eigenschappen van de sensor weer
op de **default deselect** te zetten

*set\_sensor\_select* – functie om de eigenschappen van de sensoren op
**select** te zetten. Bij het toekennen van een kleur wordt bepaald
welke kleur nog vrij is. Als de groepsselectie aan staat
(actiegroep==TRUE) wordt de kleur en naam van die groep toegekend.

*add\_sensors\_map* – functie voor het toevoegen van de sensoren op de
kaart

*calc\_groep\_mean* – functie om per groep het gemiddelde te berekenen

#### Overzicht van de ObserveEvents

Met de keuzes zoals *‘kies component’* wilt u direct de waardes zien
veranderen. Dit soort directe interacties worden bijgehouden in een
**‘observeEvent’**. Ook het selecteren van de sensoren gaat hiermee.

Net als bij de functies volgt hier een korte beschrijving van de
verschillende observeEvents:

*observeEvent({input$A\_groep} …)* – houdt in de gaten of er een groep
moet worden geselecteerd of een losse sensor.

*observeEvent({input$Text\_groep} …)* – houdt in de gaten welke
groepsnaam er is opgegeven

*observeEvent({input$map\_marker\_click$id} …)* – houdt in de gaten of
er sensor wordt aangeklikt. Zoja, dan selecteert-ie de sensor en laat de
nieuwe kleur op de kaart zien.

*observeEvent(input$reset, …)* – wanneer er op de reset button wordt
geklikt, wordt de kleur en selected van alle sensoren weer op default
gezet

*observeEvent(input$map\_draw\_new\_feature … )* en
*observeEvent(input$map\_draw\_deleted\_features …)* – voor de
multiselect die al bij de leaflet-kaart wordt meegegeven. Om gebruik te
kunnen maken van en handmatig en via multiselect te selecteren, zijn
deze functies om die beide te combineren. Het houdt expliciet bij wat
geselecteerd is met multiselect, om dat ook met de reset button te
kunnen deselecteren.

Nawoord
-------

Wij hopen u hiermee voldoende rondleiding te hebben gegeven, dat u nu
op eigen initiatief de R-scripts zelf kunt bekijken en uitbreiden.
Meldingen van errors of opmerkingen over de code graag via een *Issue* 
op GitHub zelf, u hebt hiervoor wel een eigen account nodig. 
>>>>>>> upstream/master
