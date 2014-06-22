## This script explores the data set of Fine Particulate Matter of US from 1999 to 2008 and
## tries to establish a trend of the emmision of various types of particulate
## of Baltimore City, Maryland with the time.

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

# Subset the data of only Baltimore City and set the row.names to NULL
baltimoreData <- PED[PED[, "fips"] == "24510", ]
row.names(baltimoreData) <- NULL

# Opens the graphics device
png(filename="./plot3.png", height = 240, width = 680, units="px")

# load the ggplot2 library
library(ggplot2)

# Plot the graph of total emmisions against the year measured along with appropriate main title
qplot(year, Emissions, data = baltimoreData, facets = .~type, binwidth=2, geom=c("point", "smooth"), method="lm") + labs(title="Type Wise Emission from Baltimore City")

# Close the graphics device
dev.off()