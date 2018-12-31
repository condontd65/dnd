#library(googlesheets)
library(tidyverse)
library(stringr)
library(dplyr)
library(qdap)
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

# Prep bad table for individualized analysis by removing unecessary data
