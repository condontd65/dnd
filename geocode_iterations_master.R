library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)
library(xlsx)

gs_auth(new_user = TRUE)

# Check available sheets
gs_ls()
available <- gs_ls()

# Bring in main datasheet to geocode
master <- gs_title("AFFORDABLE HOUSING MASTER LIST")
master <- gs_read(master, ws = 3)
colnames(master) <- master[1,]
master <- master[2:2946, ]

master <- tibble::rowid_to_column(master,'geoid')
master$geoaddress <- paste(master$Parcel_Address, master$ZipCode)

master.orig <- master
master.geordy <- data.table(master$geoaddress, master$geoid)
colnames(master.geordy) <- c('geoaddress','geoid')

write.xlsx(master.geordy, "tables/master/master_geo.xlsx", row.names = FALSE)
  
##### Read in first iteration done in arcgis
master.run1 <- read.xlsx("tables/master/master_georun_1.xlsx", sheetIndex = 1)
master.run1.good <- subset(master.run1, master.run1$Score > 10)
master.run1.bad <- subset(master.run1, master.run1$Score <= 10)
rm(master.run1)
rm(master.geordy)
rm(master)

master.run1.failed <- data.table(master.run1.bad$Address_Text, master.run1.bad$geoid)
colnames(master.run1.failed) <- c('Address_Text','geoid')

write.csv(master.run1.failed, "tables/master/master_georun_1_failed.csv" ,row.names = FALSE)

##### Read in the second iteration
master.run2 <- read.csv("tables/master/master_georun_2.csv") #385
master.run2 <- master.run2[1:385,]
master.run2.good <- subset(master.run2, master.run2$Match.Score > 2)
master.run2.bad <- subset(master.run2, master.run2$Match.Score <= 2)
rm(master.run2)

master.run2.failed <- data.table(master.run2.bad$Address.Text, master.run2.bad$geoid)
colnames(master.run2.failed) <- c('Address_Text','geoid')

write.csv(master.run2.failed, "tables/master/master_georun_2_failed.csv", row.names = FALSE)

##### Read in manually found locations
master.run3 <- read.csv("tables/master/master_georun_3.csv")
master.run3.good <- subset(master.run3, !is.na(master.run3$sam_id))
master.run3.bad <- subset(master.run3, is.na(master.run3$sam_id))

### Merge all sf together
# Create tables of the matched data contianing only the geodid and the SAMID
master.r1 <- data.table(master.run1.good$Ref_ID, master.run1.good$geoid)
colnames(master.r1) <- c("SAM_ID", "geoid")

master.r2 <- data.table(master.run2.good$Match.Id, master.run2.good$geoid)
colnames(master.r2) <- c("SAM_ID", "geoid")

master.r3 <- data.table(master.run3.good$sam_id, master.run3.good$geoid)
colnames(master.r3) <- c("SAM_ID", "geoid")

master.no <- data.table(master.run3.bad$sam_id, master.run3.bad$geoid)
colnames(master.no) <- c("SAM_ID", "geoid")
master.no$SAM_ID <- NA


# Still need to merge them all together and order by geoid
master.geo <- rbind(master.r1, master.r2, master.r3, master.no)
master.geo <- master.geo[order(geoid),]

master.complete <- merge(master.orig, master.geo, by = "geoid")

write.csv(master.complete, "tables/master/master_samid.csv", row.names = FALSE)
gs_upload("tables/master/master_samid.csv",
          sheet_title = "Master SAM ID")
























