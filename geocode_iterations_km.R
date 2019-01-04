#library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)

# Bring in the first round of geocoded data
km.run1 <- read.csv("tables/km/km_georun_1.csv")
km.run1 <- km.run1[,1:12]

# Separate the bad and good runs
km.run1.g <- subset(km.run1, Match.Score > 0)
km.run1.b <- subset(km.run1, Match.Score == 0)
rm(km.run1)

# Export for examination alongside
write.csv(km.run1.b, "tables/km/km_georun_1_failed.csv", row.names = FALSE)


# Append zip codes and remove neighborhoods
km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Allston/Brighton", "02135", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Back Bay", "02115", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Bay Village", "02116", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Beacon Hill", "02108", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Charlestown", "02129", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Chinatown", "02111", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Back Bay/Beacon Hill", "0211", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Dorchester", "02121", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Fenway/Kenmore", "02115", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Financial District/Downtown", "02108", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Hyde Park", "02136", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Jamaica Plain", "02130", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Mattapan", "02126", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Mission Hill", "02120", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Back Bay", "02115", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("North End", "02113", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Roslindale", "02131", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("Roxbury", "02119", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("South Boston", "02127", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("South End", "02118", x)
}))

km.run1.b <- data.frame(lapply(km.run1.b, function(x) {
  gsub("West End", "02114", x)
}))

# Write csv for the unmatched addresses
#write.csv(km.run1.b, "tables/km/km_georun_1_failed.csv", row.names = FALSE)


## Bring in second run of km
km.run2 <- read.csv("tables/km/km_georun_2.csv")

# Separate the bad and good runs
km.run2.g <- subset(km.run2, Match.Score > 0)
km.run2.b <- subset(km.run2, Match.Score == 0)
rm(km.run2)

# Fix caps
km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("ALLSTON/BRIGHTON", "02135", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("BACK BAY", "02115", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("BAY VILLAGE", "02116", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("BEACON HILL", "02108", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("CHARLESTOWN", "02129", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("CHINATOWN", "02111", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("DORCHESTER", "02121", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("FENWAY/KENMORE", "02115", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("FINANCIAL DISTRICT/DOWTOWN", "02108", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("HYDE PARK", "02136", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("JAMAICA PLAIN", "02130", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("MATTAPAN", "02126", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("MISSION HILL", "02120", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("BACK BAY", "02115", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("NORTH END", "02113", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("ROSLINDALE", "02131", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("ROXBURY", "02119", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("SOUTH BOSTON", "02127", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("SOUTH END", "02118", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("WEST END", "02114", x)
}))


# Set some custom replacements
km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("02115/02108", "02116", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("East Boston", "02128", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("EAST BOSTON", "02128", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("Central", "02111", x)
}))

km.run2.b <- data.frame(lapply(km.run2.b, function(x) {
  gsub("CENTRAL", "02111", x)
}))

# write csv for the unmatched addresses in the second run
write.csv(km.run2.b, "tables/km/km_georun_2_failed.csv", row.names = FALSE)


## Run 3 for km
km.run3 <- read.csv("tables/km/km_georun_3.csv")

# Separate the bad and good runs
km.run3.g <- subset(km.run3, Match.Score > 0)
km.run3.b <- subset(km.run3, Match.Score == 0)
rm(km.run3)

#write.csv(km.run3.b, "tables/km/km_georun_3_failed.csv", row.names = FALSE)


## Run 4 for km
km.run4 <- read.csv("tables/km/km_georun_4.csv")
km.run4 <- km.run4[,1:19]

# Separate the bad and good runs
km.run4.g <- subset(km.run4, Score >= 80)
km.run4.b <- subset(km.run4, Score < 80)
rm(km.run4)

km.run4.b <- data.table(km.run4.b$Address_Text, km.run4.b$Matched,
                        km.run4.b$Match_Score, km.run4.b$Match_Text,
                        km.run4.b$Match_type, km.run4.b$Match_Id,
                        km.run4.b$MatchXCoordinate, km.run4.b$MatchYCoordinate,
                        km.run4.b$MatchLatitude, km.run4.b$MatchLongitude,
                        km.run4.b$Match_Codes, km.run4.b$geoid)

#write.csv(km.run4.b, "tables/km/km_georun_4_failed.csv", row.names = FALSE)


## Run 5 of km
km.run5 <- read.csv("tables/km/km_georun_5.csv")

# Separate the bad and good runs
km.run5.g <- subset(km.run5, Match.Score > 0)
km.run5.b <- subset(km.run5, Match.Score == 0)
rm(km.run5)

#write.csv(km.run5.b, "tables/km/km_georun_5_failed.csv", row.names = FALSE)


## Run 6 of km
km.run6 <- read.csv("tables/km/km_georun_6.csv")

# Separate the bad and good runs
km.run6.g <- subset(km.run6, Match.Score > 0)
km.run6.b <- subset(km.run6, is.na(Match.Score))
rm(km.run6)



### Merge all km together
# Create tables of the matched data contianing only the geodid and the SAMID
km.r1 <- data.table(km.run1.g$Match.Id, km.run1.g$geoid)
colnames(km.r1) <- c("SAM_ID", "geoid")

km.r2 <- data.table(km.run2.g$Match.Id, km.run2.g$geoid)
colnames(km.r2) <- c("SAM_ID", "geoid")

km.r3 <- data.table(km.run3.g$Match.Id, km.run3.g$geoid)
colnames(km.r3) <- c("SAM_ID", "geoid")

km.r4 <- data.table(km.run4.g$Ref_ID, km.run4.g$geoid)
colnames(km.r4) <- c("SAM_ID", "geoid")

km.r5 <- data.table(km.run5.g$Match.Id, km.run5.g$geoid)
colnames(km.r5) <- c("SAM_ID", "geoid")

km.r6 <- data.table(km.run6.g$Match.Id, km.run6.g$geoid)
colnames(km.r6) <- c("SAM_ID", "geoid")

km.no <- data.table(km.run6.b$Match.Id, km.run6.b$geoid)
colnames(km.no) <- c("SAM_ID", "geoid")
km.no$SAM_ID <- NA

rm(km.run1.b, km.run1.g, km.run2.b, km.run2.g, km.run3.b, km.run3.g, km.run4.b, km.run4.g, km.run5.b, km.run5.g,
   km.run6.b, km.run6.g)

# Still need to merge them all together and order by geoid

#bpda.address.geo.all <- rbind(bpda.addres.geo.all, bpda.address.geo3)












