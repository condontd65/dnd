library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
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

km.orig <- gs_title("Copy of KM Housing Master 2011 to 12.28.18")
km.orig <- gs_read(km.orig)
km.orig.colnames <- km.orig


#km.orig.colnames <- as.matrix(km.orig.colnames)
#colnames(km.orig) <- km.orig.colnames[1,]
colnames(km.orig) <- km.orig[16,]

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

#write.csv(km.geordy, "tables/km_house_geo.csv", row.names = FALSE)
#write.csv(masslist.geordy, "tables/masslist_geo.csv", row.names = FALSE)
#write.csv(nhpd.geordy, "tables/nhpd_geo.csv", row.names = FALSE)

rm(km, km.cols, km.orig.colnames, masslist, masslist.geordy, nhpd, nhpd.geordy, km.geordy)

### Next three tables
## sf, cedac, hu
# Bring in three new datasheets to merge

sf.orig <- gs_title("Salesforce Projects wProject Units wCovenants_1.2.19")
sf.orig <- gs_read(sf.orig)

hu.orig <- gs_title("HU Multifamily Assistance & Sec 8 Contract thru 2017")
hu.orig <- gs_read(hu.orig)

cedac.orig <- gs_title("CEDAC - EUR Master Q3-18 Report")
cedac.orig <- gs_read(cedac.orig)

# Create unique geo_id to reconnect geo info to tables. This is done on all for consistency
cedac.orig <- tibble::rowid_to_column(cedac.orig,'geoid')
hu.orig <- tibble::rowid_to_column(hu.orig, 'geoid')
sf.orig <- tibble::rowid_to_column(sf.orig, 'geoid')

# Create new columns for geocoding addresses after creating additional datasets
cedac <- cedac.orig
hu <- hu.orig
sf <- sf.orig

cedac$geoaddress <- paste(cedac$Address, cedac$Zip)
hu$geoaddress <- paste(hu$address_line1_text, hu$zip_code)
sf$geoaddress <- paste(sf$`Unit Street #`, sf$`Unit Street Name`, sf$`Unit ZIP`)

# Prep datasets for export into csv and geocoding
cedac.geordy <- data.table(cedac$geoaddress, cedac$geoid)
colnames(cedac.geordy) <- c('geoaddress','geoid')

hu.geordy <- data.table(hu$geoaddress, hu$geoid, hu$zip_code)
colnames(hu.geordy) <- c('geoaddress','geoid','zip')

# Keep nhpd zips for cleaning purposes
sf.geordy <- data.table(sf$geoaddress, sf$geoid)
colnames(sf.geordy) <- c('geoaddress','geoid')

# Write three new datasets to csv for geocoding
write.csv(cedac.geordy, "tables/cedac/cedac_geo.csv", row.names = FALSE)
write.csv(hu.geordy, "tables/hu/hu_geo.csv", row.names = FALSE)
write.csv(sf.geordy, "tables/sf/sf_geo.csv", row.names = FALSE)

rm(sf, sf.cols, cedac, cedac.geordy, hu, hu.geordy, sf.geordy)













