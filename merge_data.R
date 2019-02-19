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

hu <- hu [ !is.na(hu$SAM_ID) ]
hu <- hu [ !(is.na(hu$mgmt_agent_org_name) & is.na(hu$mgmt_agent_main_phone_number) & is.na(hu$mgmt_agent_email_text)) ]

# Merge HU and replace columns
master.hu <- merge(master.1, hu,  by = "SAM_ID", all.y = FALSE, all.x = TRUE)
master.hu <- unique(master.hu)

master.hu <- master.hu[order(master.hu$geoid),]
n_occur <- data.frame(table(master.hu$geoid))
n_occur[n_occur$Freq > 1,]

# Replace
master.hu$ManagementCompany [ !is.na(master.hu$mgmt_agent_org_name) ] <- 
  master.hu$mgmt_agent_org_name [ !is.na(master.hu$mgmt_agent_org_name) ]

master.hu$MainOffice [ !is.na(master.hu$mgmt_agent_main_phone_number) ] <-
  master.hu$mgmt_agent_main_phone_number [ !is.na(master.hu$mgmt_agent_main_phone_number) ]

master.hu$ManagementEmail <- master.hu$mgmt_agent_email_text

master.2 <- master.hu


# Bring in KM
km <- gs_title('KM SAM ID')
km <- gs_read(km)
km <- data.table(km$SAM_ID, km$SalesForceURL, km$`Complete Date`)
colnames(km) <- c('SAM_ID', 'SalesForce', 'Complete Date')

km$SalesForce [ km$SalesForce == 0 ] <- NA
km <- km [ !is.na(km$SAM_ID) ]
km <- km [ !(is.na(km$SalesForce) & is.na(km$`Complete Date`)) ]

master.km <- merge(master.2, km, by = "SAM_ID", all.y = FALSE, all.x = TRUE)
master.km <- unique(master.km)

#Replace
master.km$Salesforce_Link <- master.km$Salesforce_link_text

master.km$Salesforce_Link [ !is.na(master.km$SalesForce) ] <- 
  master.km$SalesForce [ !is.na(master.km$SalesForce) ]

master.km$Salesforce_Link [ master.km$Salesforce_Link == "0" ] <- NA

master.km$Date [ !is.na(master.km$`Complete Date`) ] <-
  master.km$`Complete Date` [ !is.na(master.km$`Complete Date`) ]

master.km$Date_Type [ !is.na(master.km$Date) ] <- "complete"

master.3 <- master.km


# Bring in MassHousing (Masslist)
ml <- gs_title('Masslist SAM ID')
ml <- gs_read(ml)
ml <- data.table(ml$SAM_ID, ml$Management_Company, ml$Main_Office, ml$Site_Office, ml$ELD, ml$PB_Subsidy, ml$MH_Financed)
colnames(ml) <- c('SAM_ID', 'Management_Company', 'Main_Office', 'Site_Office', 'ELD', 'PB_Subsidy', 'MH_Financed')

ml <- ml [ !is.na(ml$SAM_ID) ]
ml <- ml [ !(is.na(ml$Management_Company) & is.na(ml$Main_Office) & is.na(ml$Site_Office) & is.na(ml$ELD) &
               is.na(ml$PB_Subsidy) & is.na(ml$MH_Financed)) ]

master.ml <- merge(master.3, ml, by = "SAM_ID", all.y = FALSE, all.x = TRUE)
master.ml <- unique(master.ml)

# Replace
master.ml$ManagementCompany [ !is.na(master.ml$Management_Company) ] <-
  master.ml$Management_Company [ !is.na(master.ml$Management_Company) ]

master.ml$MainOffice [ !is.na(master.ml$Main_Office) ] <- 
  master.ml$Main_Office [ !is.na(master.ml$Main_Office) ]

master.ml$SiteOffice [ !is.na(master.ml$Site_Office) ] <-
  master.ml$Site_Office [ !is.na(master.ml$Site_Office) ]

master.ml$ElderlyUnits [ !is.na(master.ml$ElderlyUnits) | !is.na(master.ml$ELD) ] <- 
  master.ml$ELD [ !is.na(master.ml$ElderlyUnits) | !is.na(master.ml$ELD) ]

master.ml$Section_8 [ master.ml$PB_Subsidy == "X" ] <- "x"

master.4 <- master.ml


# Bring in NHPD  
nhpd <- gs_title('NHPD SAM ID') %>%
  gs_read()
nhpd <- data.table(nhpd$SAM_ID, nhpd$EarliestStartDate, nhpd$LatestEndDate, nhpd$ManagerName, nhpd$TargetTenantType, nhpd$S8_1_Status,
                   nhpd$S8_2_Status, nhpd$S202_1_Status, nhpd$FHA_1_Status, nhpd$FHA_2_Status,
                   nhpd$LIHTC_1_Status, nhpd$HOME_1_Status, nhpd$PH_1_Status)
colnames(nhpd) <- c('SAM_ID','EarliestStartDate','LatestEndDate','ManagerName','TargetTenantType','S8_1_Status','S8_2_Status',
                    'S202_1_Status','FHA_1_Status','FHA_2_Status','LIHTC_1_Status','HOME_1_Status','PH_1_Status')

nhpd <- nhpd [ !is.na(nhpd$SAM_ID) ]
nhpd <- nhpd [ !(is.na(nhpd$EarliestStartDate) & is.na(nhpd$LatestEndDate) & is.na(nhpd$ManagerName) & is.na(nhpd$TargetTenantType) &
                   is.na(nhpd$S8_1_Status) & is.na(nhpd$S8_2_Status) & is.na(nhpd$S202_1_Status) & is.na(nhpd$FHA_1_Status) &
                   is.na(nhpd$FHA_2_Status) & is.na(nhpd$LIHTC_1_Status) & is.na(nhpd$HOME_1_Status) & is.na(nhpd$PH_1_Status))]

master.nhpd <- merge(master.4, nhpd, by = "SAM_ID", all.y = FALSE, all.x = TRUE)
master.nhpd <- unique(master.nhpd)

# Replace
master.nhpd$Yr_First_Submitted [ !is.na(master.nhpd$EarliestStartDate) ] <-
  master.nhpd$EarliestStartDate [ !is.na(master.nhpd$EarliestStartDate) ]

master.nhpd$Yr_End [ !is.na(master.nhpd$LatestEndDate) ] <-
  master.nhpd$LatestEndDate [ !is.na(master.nhpd$LatestEndDate) ]

master.nhpd$ManagementCompany [ !is.na(master.nhpd$ManagerName) ] <-
  master.nhpd$ManagerName [ !is.na(master.nhpd$ManagerName) ]

master.nhpd$Eldery_Flag [ (is.na(master.nhpd$Eldery_Flag) & (master.nhpd$TargetTenantType == 'Elderly' |
                             master.nhpd$TargetTenantType == 'Elderly or disabled')) ] <- "x"

master.nhpd$Disabled <- NA
master.nhpd$Disabled [ (master.nhpd$TargetTenantType == 'Disabled' |  master.nhpd$TargetTenantType == 
                          'Elderly or disabled') ] <- "x"

master.nhpd$Section_8 [ is.na(master.nhpd$S8_1_Status) &
                          master.nhpd$S8_1_Status == "Active" ] <- "x"

master.nhpd$Section_8 [ is.na(master.nhpd$S8_2_Status) &
                          master.nhpd$S8_2_Status == "Active" ] <- "x"

master.nhpd$`202` [ is.na(master.nhpd$`202`) & master.nhpd$S202_1_Status == 'Active' ] <- "x"

master.nhpd$LIHTC [ is.na(master.nhpd$LIHTC) & master.nhpd$LIHTC_1_Status == 'Active' ] <- "x"

master.5 <- master.nhpd

# Bring in Salesforce
sf <- gs_title('SF SAM ID') %>%
  gs_read()
sf <- data.table(sf$SAM_ID, sf$`Covenant Start Date`, sf$`Covenant End Date`, sf$`Management Company: Account Name`,
                 sf$`Property Manager Contact Phone`)
colnames(sf) <- c('SAM_ID','Covenant_Start_Date','Covenant_End_Date','ManagementCompanyManager','PropertyManagerPhone')

sf <- sf [ !is.na(sf$SAM_ID) ]
sf <- sf [ !(is.na(sf$Covenant_Start_Date) & is.na(sf$Covenant_End_Date) & is.na(sf$ManagementCompanyManager) & 
               is.na(sf$PropertyManagerPhone)) ]

master.sf <- merge(master.5, sf, by = "SAM_ID", all.y = FALSE, all.x = TRUE)
master.sf <- unique(master.sf)



#master.cedac <- master[order(master$SAM_ID),]
n_occur <- data.frame(table(master.sf$SAM_ID))
n_occur[n_occur$Freq > 1,]



























