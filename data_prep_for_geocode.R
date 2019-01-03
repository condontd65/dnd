library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
library(qdap)
library(data.table)
library(DescTools)
library(zoo)

# Authenticate google
gs_auth(new_user = TRUE)

# Check available sheets
gs_ls()
available <- gs_ls()

# Bring in various datasheets to merge
masslist.orig <- gs_title("MassHousingList_Boston_12-17-2018")
masslist.orig <- gs_read(masslist.orig)

nhpd.orig <- gs_title("NHPD Database 2018")
nhpd.orig <- gs_read(nhpd.orig)

km.orig <- gs_title("KM Housing Master 2011 to 12.28.18")
km.orig <- gs_read(km.orig)
km.orig.colnames <- km.orig


km.orig.colnames <- as.matrix(km.orig.colnames)
colnames(km.orig) <- km.orig.colnames[1,]

# Create unique geo_id to reconnect geo info to tables. This is done on all for consistency
masslist.orig <- tibble::rowid_to_column(masslist.orig,'geoid')
nhpd.orig <- tibble::rowid_to_column(nhpd.orig, 'geoid')
km.orig <- tibble::rowid_to_column(km.orig, 'geoid')

# Remove unecessary header from km
km <- km.orig[17:4313,] %>%
  data.table()
nhpd <- nhpd.orig
masslist <- masslist.orig

# Name column
km.cols <- km.orig[16,]
km.cols <- data.frame(lapply(km.cols, function(x) {
  gsub(" ", ".", x)
}))
km.cols <- as.matrix(km.cols)
colnames(km) <- as.character(km.cols[1,])
km$geoid <- km$`16`

# Remove rows without street number or address columns
km <- subset(km, !is.na(km$Street.Number))

# Create new columns for geocoding addresses
km$geoaddress <- paste(km$Street.Number, km$Street.Name, km$St.Suffix, km$Planning.District)
km$geoaddress <- gsub(pattern = "NA ", km$geoaddress, replacement = "")
km$geoaddress <- gsub(pattern = " NA", km$geoaddress, replacement = "")

masslist$City <- gsub(pattern = "Boston - ", masslist$City, replacement = "")
masslist$geoaddress <- paste(masslist$Address, masslist$City)

nhpd$geoaddress <- paste(nhpd$`Property Address`, nhpd$City, nhpd$Zip)

# Create new tables to export with just the relevant data
km.geordy <- data.table(km$geoaddress, km$geoid)
colnames(km.geordy) <- c('geoaddress','geoid')
  
masslist.geordy <- data.table(masslist$geoaddress, masslist$geoid)
colnames(masslist.geordy) <- c('geoaddress','geoid')

# Keep nhpd zips for cleaning purposes
nhpd.geordy <- data.table(nhpd$geoaddress, nhpd$geoid, nhpd$Zip)
colnames(nhpd.geordy) <- c('geoaddress','geoid','zip')

write.csv(km.geordy, "tables/km_house_geo.csv", row.names = FALSE)
write.csv(masslist.geordy, "tables/masslist_geo.csv", row.names = FALSE)
write.csv(nhpd.geordy, "tables/nhpd_geo.csv", row.names = FALSE)
























