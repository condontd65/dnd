library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)

# Bring in the first round of geocoded data
cedac.run1 <- read.csv("tables/cedac/cedac_georun_1.csv")
cedac.run1 <- cedac.run1[,1:12]

# Separate the bad and good runs
cedac.run1.g <- subset(cedac.run1, Match.Score > 0)
cedac.run1.b <- subset(cedac.run1, Match.Score == 0)
rm(cedac.run1)

# Remove "NA" from address
cedac.run1.b <- data.frame(lapply(cedac.run1.b, function(x) {
  gsub(" NA", "", x)
}))

# Write to be run in boston composite
write.csv(cedac.run1.b, "tables/cedac/cedac_georun_1_failed.csv", row.names = FALSE)


## 2nd run of geocode from composite geocoder
cedac.run2 <- read.csv("tables/cedac/cedac_georun_2.csv")
cedac.run2 <- cedac.run2[,1:17]
cedac.run2.g <- subset(cedac.run2, Score >= 80)
cedac.run2.b <- subset(cedac.run2, Score < 80)
rm(cedac.run2)

cedac.run2.b <- cedac.run2.b[,6:17]

write.csv(cedac.run2.b, "tables/cedac/cedac_georun_2_failed.csv", row.names = FALSE)


## 3rd run of geocode from manual
cedac.run3 <- read.csv("tables/cedac/cedac_georun_3.csv")
cedac.run3.g <- subset(cedac.run3, Match_Score > 10)
cedac.run3.b <- subset(cedac.run3, is.na(Match_Score))


### Merge all cedac together
# Create tables of the matched data contianing only the geodid and the SAMID
cedac.r1 <- data.table(cedac.run1.g$Match.Id, cedac.run1.g$geoid)
colnames(cedac.r1) <- c("SAM_ID", "geoid")

cedac.r2 <- data.table(cedac.run2.g$Ref_ID, cedac.run2.g$geoid)
colnames(cedac.r2) <- c("SAM_ID", "geoid")

cedac.r3 <- data.table(cedac.run3.g$Match_Id, cedac.run3.g$geoid)
colnames(cedac.r3) <- c("SAM_ID", "geoid")

cedac.no <- data.table(cedac.run3.b$Match_Id, cedac.run3.b$geoid)
colnames(cedac.no) <- c("SAM_ID", "geoid")
cedac.no$SAM_ID <- NA





