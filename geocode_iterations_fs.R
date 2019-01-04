library(tidyverse)
library(stringr)
library(dplyr)
#library(qdap)
library(data.table)
library(DescTools)
library(zoo)

# Bring in the first round of geocoded data
sf.run1 <- read.csv("tables/sf/sf_georun_1.csv")
sf.run1 <- sf.run1[,1:12]

# Separate the bad and good runs
sf.run1.g <- subset(sf.run1, Match.Score > 0)
sf.run1.b <- subset(sf.run1, Match.Score == 0)
rm(sf.run1)