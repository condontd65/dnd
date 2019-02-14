library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)
library(googlesheets)
library(xlsx)

# Bring in the first round of geocoded data
sf.run1 <- read.csv("tables/sf/sf_georun_1.csv")
sf.run1 <- sf.run1[,1:12]

# Separate the bad and good runs
sf.run1.g <- subset(sf.run1, Match.Score > 0)
sf.run1.b <- subset(sf.run1, Match.Score == 0)
rm(sf.run1)

# Write to csv for running through the composite geocoder
write.csv(sf.run1.b, "tables/sf/sf_georun_1_failed.csv", row.names = FALSE)


## Bring in second geocode run from boston composite in arc
sf.run2 <- read.csv("tables/sf/sf_georun_2.csv")
sf.run2 <- sf.run2[,1:17]
# Separate the bad and good runs
sf.run2.g <- subset(sf.run2, Score >= 80)
sf.run2.b <- subset(sf.run2, Score < 80)
rm(sf.run2)

write.csv(sf.run2.b, "tables/sf/sf_georun_2_failed.csv", row.names = FALSE)


## Bring in third geocode from manual SAM checks
sf.run3 <- read.csv("tables/sf/sf_georun_3.csv")

# Separate the bad and good runs
sf.run3.g <- subset(sf.run3, !is.na(Match_Id))
sf.run3.b <- subset(sf.run3, is.na(Match_Id))
rm(sf.run3)


### Merge all sf together
# Create tables of the matched data contianing only the geodid and the SAMID
sf.r1 <- data.table(sf.run1.g$Match.Id, sf.run1.g$geoid)
colnames(sf.r1) <- c("SAM_ID", "geoid")

sf.r2 <- data.table(sf.run2.g$Ref_ID, sf.run2.g$geoid)
colnames(sf.r2) <- c("SAM_ID", "geoid")

sf.r3 <- data.table(sf.run3.g$Match_Id, sf.run3.g$geoid)
colnames(sf.r3) <- c("SAM_ID", "geoid")

sf.no <- data.table(sf.run3.b$Match_Id, sf.run3.b$geoid)
colnames(sf.no) <- c("SAM_ID", "geoid")
sf.no$SAM_ID <- NA


# Still need to merge them all together and order by geoid
#bpda.address.geo.all <- rbind(bpda.addres.geo.all, bpda.address.geo3)

sf.geo <- rbind(sf.r1, sf.r2, sf.r3, sf.no)
sf.geo <- sf.geo[order(geoid),]

sf.complete <- merge(sf.orig, sf.geo, by = "geoid")

#write.csv(sf.geo, "tables/sf/sf_samid.csv", row.names = FALSE)
write.csv(sf.complete, "tables/sf/sf_samid.csv", row.names = FALSE)
gs_upload("tables/sf/sf_samid.csv",
          sheet_title = "SF SAM ID")





















