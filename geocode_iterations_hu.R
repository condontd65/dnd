library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)
library(RODBC)
library(leaflet)
library(leaflet.esri)
library(leaflet.extras)
library(rjson)
library(rgdal)
library(rgeos)

# Bring in the first round of geocoded data
hu.run1 <- read.csv("tables/hu/hu_georun_1.csv")

# Fix the zip codes so they have a zero in front
hu.run1$zip <- as.character(hu.run1$zip)
hu.run1$zip <- str_pad(hu.run1$zip, 5, pad = "0")

hu.run1$zip <- substr(hu.run1$zip, 0, 5)

# Separate the bad and good runs
hu.run1.g <- subset(hu.run1, Match.Score > 0)
hu.run1.b <- subset(hu.run1, Match.Score == 0)
rm(hu.run1)


## Bring in known Boston zips
vsql22dsn <- c("MSSQL:server=vsql22;database=EGIS;
               trusted_connection=yes")

# 102686 EPSG
projstring <- CRS("+proj=lcc +lat_1=41.71666666666667 +lat_2=42.68333333333333 +lat_0=41 +lon_0=-71.5 +x_0=200000 +y_0=750000.0000000001 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")

# ogrListLayers(vsql22dsn)
lyr <- c("doit.ZIPCODES")
spdf <- readOGR(dsn = vsql22dsn, layer = lyr)

# Define coordinate system
proj4string(spdf) <- projstring

zips.4326 <- spTransform(spdf, CRS("+init=epsg:4326"))

zips.4326$ZIP5
zips <- zips.4326

# Match lists and keep relevant zip codes
hu.run1.b.rel <- hu.run1.b
hu.run1.b.notboston <- hu.run1.b
hu.run1.b.rel <- filter(hu.run1.b.rel, zip %in% zips$ZIP5)
hu.run1.b.notboston <- filter(hu.run1.b.notboston, !(zip %in% zips$ZIP5))
hu.run1.b <- hu.run1.b.rel

rm(projstring, spdf, zips, zips.4326)

# Write to be run in boston composite
write.csv(hu.run1.b, "tables/hu/hu_georun_1_failed.csv", row.names = FALSE)


## Bring in run 2 from the boston composite in arc
hu.run2 <- read.csv("tables/hu/hu_georun_2.csv")
hu.run2 <- hu.run2[,1:17]

hu.run2.g <- subset(hu.run2, Score >= 80)
hu.run2.b <- subset(hu.run2, Score < 80)
rm(hu.run2)

# Write to csv to be looked at compared to SAM directly
write.csv(hu.run2.b, "tables/hu/hu_georun_2_failed.csv", row.names = FALSE)


## Bring in run 3 manual try
hu.run3 <- read.csv("tables/hu/hu_georun_3.csv")
#hu.run3 <- hu.run2[,1:17]

hu.run3.g <- subset(hu.run3, !is.na(Match_Id))
hu.run3.b <- subset(hu.run3, is.na(Match_Id))
rm(hu.run3)


### Merge all hu together
# Create tables of the matched data contianing only the geodid and the SAMID
hu.r1 <- data.table(hu.run1.g$Match.Id, hu.run1.g$geoid)
colnames(hu.r1) <- c("SAM_ID", "geoid")

hu.r2 <- data.table(hu.run2.g$Ref_ID, hu.run2.g$geoid)
colnames(hu.r2) <- c("SAM_ID", "geoid")

hu.r3 <- data.table(hu.run3.g$Match_Id, hu.run3.g$geoid)
colnames(hu.r3) <- c("SAM_ID", "geoid")

hu.no <- data.table(hu.run3.b$Match_Id, hu.run3.b$geoid)
colnames(hu.no) <- c("SAM_ID", "geoid")
hu.no$SAM_ID <- NA

hu.no.none <- data.table(hu.run1.b.notboston$Match.Id, hu.run1.b.notboston$geoid)
colnames(hu.no.none) <- c("SAM_ID", "geoid")
hu.no.none$SAM_ID <- NA


















