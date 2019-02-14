library(googlesheets)
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
nhpd.run1 <- read.csv("tables/nhpd/nhpd_georun_1.csv")
nhpd.run1 <- nhpd.run1[,1:13]

# Separate the bad and good runs
nhpd.run1.g <- subset(nhpd.run1, Match.Score > 0)
nhpd.run1.b <- subset(nhpd.run1, Match.Score == 0)
rm(nhpd.run1)

# Clean up the zip codes to match with a list of known zips in Boston (SAM)
nhpd.run1.b$zip <- substr(nhpd.run1.b$zip, 0, 5)

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
nhpd.run1.b.rel <- nhpd.run1.b
nhpd.run1.b.notboston <- nhpd.run1.b
nhpd.run1.b.rel <- filter(nhpd.run1.b.rel, zip %in% zips$ZIP5)
nhpd.run1.b.notboston <- filter(nhpd.run1.b.notboston, !(zip %in% zips$ZIP5))
nhpd.run1.b <- nhpd.run1.b.rel

# Write to a csv to run through composite geocoder
write.csv(nhpd.run1.b, "tables/nhpd/nhpd_georun_1_failed.csv", row.names = FALSE)


## Run 2
nhpd.run2 <- read.csv("tables/nhpd/nhpd_georun_2.csv")
nhpd.run2 <- nhpd.run2[,1:17]

# Separate the bad and good runs
nhpd.run2.g <- subset(nhpd.run2, Score >= 80)
nhpd.run2.b <- subset(nhpd.run2, Score < 80)
rm(nhpd.run2)
nhpd.run2.b <- nhpd.run2.b[,6:17]
#nhpd.run2.g <- nhpd.run2.g[,6:17]

# Write to csv to match to SAM ID with third, manual geocode
write.csv(nhpd.run2.b, "tables/nhpd/nhpd_georun_2_failed.csv", row.names = FALSE)


## Run 3 (final run)
nhpd.run3 <- read.csv("tables/nhpd/nhpd_georun_3.csv")

# Separate the bad and good runs
nhpd.run3.g <- subset(nhpd.run3, Match.Score > 0)
nhpd.run3.b <- subset(nhpd.run3, is.na(Match.Score))
rm(nhpd.run3)


### Merge all nhpd together
# Create tables of the matched data contianing only the geodid and the SAMID
nhpd.r1 <- data.table(nhpd.run1.g$Match.Id, nhpd.run1.g$geoid)
colnames(nhpd.r1) <- c("SAM_ID", "geoid")

nhpd.r2 <- data.table(nhpd.run2.g$Ref_ID, nhpd.run2.g$geoid)
colnames(nhpd.r2) <- c("SAM_ID", "geoid")

nhpd.r3 <- data.table(nhpd.run3.g$Match.Id, nhpd.run3.g$geoid)
colnames(nhpd.r3) <- c("SAM_ID", "geoid")

nhpd.no <- data.table(nhpd.run1.b.notboston$Match.Id, nhpd.run1.b.notboston$geoid)
colnames(nhpd.no) <- c("SAM_ID", "geoid")
nhpd.no$SAM_ID <- NA

nhpd.no2 <- data.table(nhpd.run3.b$Match.Id, nhpd.run3.b$geoid)
colnames(nhpd.no2) <- c("SAM_ID", "geoid")
nhpd.no2$SAM_ID <- NA

rm(nhpd.run1.b, nhpd.run1.g, nhpd.run2.b, nhpd.run2.g, nhpd.run3.b, nhpd.run3.g, nhpd.run1.b.notboston,
   nhpd.run1.b.rel, projstring, spdf, zips, zips.4326)


# Still need to merge them all together and order by geoid
#bpda.address.geo.all <- rbind(bpda.addres.geo.all, bpda.address.geo3)

nhpd.geo <- rbind(nhpd.r1, nhpd.r2, nhpd.r3, nhpd.no, nhpd.no2)
nhpd.geo <- nhpd.geo[order(geoid),]

nhpd.complete <- merge(nhpd.orig, nhpd.geo, by = "geoid")

#write.csv(nhpd.geo, "tables/nhpd/nhpd_samid.csv", row.names = FALSE)
write.csv(nhpd.complete, "tables/nhpd/nhpd_samid.csv", row.names = FALSE)
gs_upload("tables/nhpd/nhpd_samid.csv",
          sheet_title = "NHPD SAM ID")











