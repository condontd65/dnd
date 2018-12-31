#library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
library(qdap)
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














##### Sample code


## Run 2
bpda.run2 <- read.csv("bpda_run2.csv")
bpda.run2 <- bpda.run2[1:69,1:16]
bpda.sam.good.run2 <- subset(bpda.run2, Match.Score > 0)

bpda.address.geo2 <- data.table(bpda.sam.good.run2$Street__,
                                bpda.sam.good.run2$Street_Name,
                                bpda.sam.good.run2$Street_suffix,
                                bpda.sam.good.run2$Unit__,
                                bpda.sam.good.run2$ZIP_1,
                                bpda.sam.good.run2$Match.Id,
                                bpda.sam.good.run2$Address)
colnames(bpda.address.geo2) <- c('Street #', 'Street Name',
                                 'Street suffix', 'Unit #', 'ZIP', 'SAM ID',
                                 'Address')

bpda.addres.geo.all <- rbind(bpda.address.geo, bpda.address.geo2)

# Run 3
bpda.run3 <- read.csv('bpda_run3.csv')
bpda.run3 <- bpda.run3[1:43,1:16]
bpda.sam.good.run3 <- subset(bpda.run3, Match.Score > 0)

bpda.address.geo3 <- data.table(bpda.sam.good.run3$Street__,
                                bpda.sam.good.run3$Street_Name,
                                bpda.sam.good.run3$Street_suffix,
                                bpda.sam.good.run3$Unit__,
                                bpda.sam.good.run3$ZIP_1,
                                bpda.sam.good.run3$Match.Id,
                                bpda.sam.good.run3$Address)
colnames(bpda.address.geo3) <- c('Street #', 'Street Name',
                                 'Street suffix', 'Unit #', 'ZIP', 'SAM ID',
                                 'Address')

bpda.address.geo.all <- rbind(bpda.addres.geo.all, bpda.address.geo3)

##### End sample code










