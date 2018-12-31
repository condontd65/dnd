#library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
library(qdap)
library(data.table)
library(DescTools)
library(zoo)

# Bring in the first round of geocoded data
nhpd.run1 <- read.csv("tables/nhpd/nhpd_georun_1.csv")
nhpd.run1 <- nhpd.run1[,1:12]

# Separate the bad and good runs
nhpd.run1.g <- subset(nhpd.run1, Match.Score > 0)
nhpd.run1.b <- subset(nhpd.run1, Match.Score == 0)
rm(nhpd.run1)

# Prep bad table for individualized analysis by removing unecessary data
