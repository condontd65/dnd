#library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)

# Bring in the first round of geocoded data
masslist.run1 <- read.csv("tables/masslist/masslist_georun_1.csv")
masslist.run1 <- masslist.run1[,1:12]

# Separate the bad and good runs
masslist.run1.g <- subset(masslist.run1, Match.Score > 0)
masslist.run1.b <- subset(masslist.run1, Match.Score == 0)
rm(masslist.run1)

# Prep bad table for individualized analysis by removing unecessary data
masslist.run1.b[, 2:11] <- ""

# Write to csv (change to xlsx in excel)
write.csv(masslist.run1.b, "tables/masslist/masslist_georun_1_failed.csv", row.names = FALSE)

# Append zip codes and remove neighborhoods
masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Allston/Brighton", "02135", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Back Bay", "02115", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Bay Village", "02116", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Beacon Hill", "02108", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Chinatown", "02111", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Back Bay", "02115", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Dorchester", "02121", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Back Bay", "02115", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Fenway/Kenmore", "02115", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Financial District/Downtown", "02108", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Hyde Park", "02136", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Jamaica Plain", "02130", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Mattapan", "02126", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Mission Hill", "02120", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Back Bay", "02115", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("North End", "02113", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Roslindale", "02131", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("Roxbury", "02119", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("South Boston", "02127", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("South End", "02118", x)
}))

masslist.run1.b <- data.frame(lapply(masslist.run1.b, function(x) {
  gsub("West End", "02114", x)
}))

#write.csv(masslist.run1.b, "tables/masslist/masslist_georun_1_failed.csv", row.names = FALSE)


### Bring in second run of masslist
masslist.run2 <- read.csv("tables/masslist/masslist_georun_2.csv")

# Separate the bad and good runs
masslist.run2.g <- subset(masslist.run2, Match.Score > 0)
masslist.run2.b <- subset(masslist.run2, Match.Score == 0)
rm(masslist.run2)

# Write to csv (change to xlsx in excel)
write.csv(masslist.run2.b, "tables/masslist/masslist_georun_2_failed.csv", row.names = FALSE)


### Bring in third run of masslist from arcgis composite
masslist.run3 <- read.csv("tables/masslist/masslist_georun_3.csv")
# Separate the bad and good runs
masslist.run3.g <- subset(masslist.run3, Score > 0)
masslist.run3.b <- subset(masslist.run3, Score  < 20)
rm(masslist.run3)


### Merge all masslist together
# Create tables of the matched data contianing only the geodid and the SAMID
ml.r1 <- data.table(masslist.run1.g$Match.Id, masslist.run1.g$geoid)
colnames(ml.r1) <- c("SAM_ID", "geoid")

ml.r2 <- data.table(masslist.run2.g$Match.Id, masslist.run2.g$geoid)
colnames(ml.r2) <- c("SAM_ID", "geoid")

ml.r3 <- data.table(masslist.run3.g$Match_Id, masslist.run3.g$geoid)
colnames(ml.r3) <- c("SAM_ID", "geoid")

ml.no <- data.table(masslist.run3.b$Match_Id, masslist.run3.b$geoid)
colnames(ml.no) <- c("SAM_ID", "geoid")
ml.no$SAM_ID <- NA

rm(masslist.run1.b, masslist.run1.g, masslist.run2.b, masslist.run2.g, masslist.run3.b, masslist.run3.g)

# Still need to merge them all together and order by geoid
#bpda.address.geo.all <- rbind(bpda.addres.geo.all, bpda.address.geo3)

masslist.geo <- rbind(ml.r1, ml.r2, ml.r3, ml.no)
masslist.geo <- masslist.geo[order(geoid),]

masslist.complete <- merge(masslist.orig, masslist.geo, by = "geoid")

#write.csv(masslist.geo, "tables/masslist/masslist_samid.csv", row.names = FALSE)
write.csv(masslist.complete, "tables/masslist/masslist_samid.csv", row.names = FALSE)
gs_upload("tables/masslist/masslist_samid.csv",
          sheet_title = "Masslist SAM ID")

















