## This script explores the data set of Fine Particulate Matter of US from 1999 to 2008 and
## tries to establish a trend of the emmision with the time.

## downloads the dataset
fileurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
download.file(fileurl, destfile="./exdata_data_NEI_data.zip", method="curl")

## lists the contents of the zip file and reads the required data
fileContents <- unzip(zipfile="./exdata_data_NEI_data.zip", list=T)
unzip("./exdata_data_NEI_data.zip")

## Change the working directory
setwd("./exdata_data_NEI_data/")

# Reads the data and sets the row.names to NULL
PED <- readRDS("summarySCC_PM25.rds")
row.names(PED) <- NULL

# Computes the data required to establish a relation
totalEmissions <- tapply(PED$Emissions, PED$year, FUN = sum)

# Set the enviroment to represent the data in the plots in decimal format
# instead of Scientific Notation
options(scipen=5)

# Set the warnings of since we are changing the colors of the barplots
options(warn=-1)

# Opens the graphics device
png(filename="./plot1.png", height = 480, width = 480, units="px")

# Plot the graph of total emmisions against the year measured
barplot(totalEmissions, col="red")

# Set the appropriate labels and title
title(main="Total Emissions from Fine Particulate Matter", xlab="Year", ylab="Total Emissions")

# Close the graphics device
dev.off()