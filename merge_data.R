library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)
library(xlsx)

# Remove all to start anew
rm(list = ls())

# Bring in Master dataset

gs_auth(new_user = TRUE)

# Check available sheets
gs_ls()
available <- gs_ls()

# Bring in main datasheet to geocode
master <- gs_title("Master SAM ID")
master.orig <- gs_read(master)
master <- master.orig

# Bring in CEDAC
cedac <- gs_title("CEDAC SAM ID")
cedac <- gs_read(cedac)
cedac <- data.table(cedac$SAM_ID, cedac$`Current Elderly Units`, cedac$`New Expiry Date`)
colnames(cedac) <- c('SAM_ID', 'Current Elderly Units', 'New Expiry Date')

cedac <- cedac [ !is.na(cedac$SAM_ID), ]
cedac <- cedac [ !(is.na(cedac$`Current Elderly Units`) & is.na(cedac$`New Expiry Date`)) ]


## Try a merge then replace
master.cedac <- merge(master, cedac, by = "SAM_ID", all.x = TRUE, all.y = FALSE)
#master.cedac <- master.cedac[order(master.cedac$geoid),]
#n_occur <- data.frame(table(master.cedac$geoid))
#n_occur[n_occur$Freq > 1,]

master.cedac$ElderlyUnits [ is.na(master.cedac$ElderlyUnits) ] <- 
  master.cedac$`Current Elderly Units` [ is.na(master.cedac$ElderlyUnits)]

master.cedac$Yr_End [ !is.na(master.cedac$`Current Elderly Units`) ] <-
  master.cedac$`New Expiry Date` [ !is.na(master.cedac$`Current Elderly Units`) ]

master.1 <- master.cedac
# Bring in HU
hu <- gs_title('HU SAM ID')
hu <- gs_read(hu)
hu <- data.table(hu$SAM_ID, hu$mgmt_agent_org_name, hu$mgmt_agent_main_phone_number, hu$mgmt_agent_email_text)
colnames(hu) <- c('SAM_ID', 'mgmt_agent_org_name', 'mgmt_agent_main_phone_number', 'mgmt_agent_email_text')

hu <- hu [ !is.na(hu$SAM_ID)]
hu <- hu [ !(is.na(hu$mgmt_agent_org_name) & is.na(hu$mgmt_agent_main_phone_number) & is.na(hu$mgmt_agent_email_text))]

# Merge HU and replace columns
master.hu <- merge(master.1, hu, by = "SAM_ID", all.y = FALSE, all.x = TRUE)
master.hu <- unique(master.hu)

master.hu <- master.hu[order(master.hu$geoid),]
n_occur <- data.frame(table(master.hu$geoid))
n_occur[n_occur$Freq > 1,]

master.hu$ManagementCompany [ !is.na(master.hu$mgmt_agent_org_name) ] <- 
  master.hu$mgmt_agent_org_name [ !is.na(master.hu$mgmt_agent_org_name) ]

master.hu$MainOffice [ !is.na(master.hu$mgmt_agent_main_phone_number) ] <-
  master.hu$mgmt_agent_main_phone_number [ !is.na(master.hu$mgmt_agent_main_phone_number) ]

master.hu$ManagementEmail <- master.hu$mgmt_agent_email_text






#master.cedac <- master[order(master$SAM_ID),]
n_occur <- data.frame(table(master$SAM_ID))
n_occur[n_occur$Freq > 1,]
