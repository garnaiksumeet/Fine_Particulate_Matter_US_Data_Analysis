## This script explores the data set of Fine Particulate Matter of US from 1999 to 2008 and
## tries to establish a trend of the emmision of particulate matter by Motor Vehicles
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

# Reads the SCC data set
SCC <- readRDS("Source_Classification_Code.rds")

# Convert the data types to char of various columns in the SCC data set
SCC$EI.Sector <- as.character(SCC$EI.Sector)
SCC$SCC.Level.Three <- as.character(SCC$SCC.Level.Three)
SCC$SCC.Level.One <- as.character(SCC$SCC.Level.One)

# Since we need to explore the data of emissions from Motor Vehicle from Baltimore City,
# we define Motor Vehicle by selecting all those instruments which come under the category
# of either Vehicles or On-Road. Since there is no clear distinction for defining a Motor Vehicle
# I assume all those which fall under the category of On-Road and are Vehicles.
# Hence we take the following approach:

# grep the column EI.Sector to get a partial list with regex- Vehicles
initialList <- unique(grep("Vehicles+", SCC$EI.Sector, value=T))

# grep the column EI.Sector to get a partial list with regex- On-Road
secondList <- unique(grep("On-Road+", SCC$EI.Sector, value=T))

# final exhaustive list of almost all comprising of Motor Vehicles
finalList <- unique(c(initialList, secondList))

# subsetting the SCC data set based on the exhaustive Motor Vehicle Emission List
completeData <- subset(SCC, EI.Sector %in% finalList)

# an almost entirely exhaustive unique list of all SCC codes
codeList <- unique(completeData$SCC)

# a simple type data conversion
codeList <- as.character(codeList)

# Subset the data of only Baltimore City and set the row.names to NULL
baltimoreData <- PED[PED[, "fips"] == "24510", ]
row.names(baltimoreData) <- NULL

# subsetting of the Particulate emission data set based on the exhaustive list of the Motor Vehicle
# SCC code list
vehicleEmissionData <- subset(baltimoreData, SCC %in% codeList)
row.names(vehicleEmissionData) <- NULL

# Set the enviroment to represent the data in the plots in decimal format
# instead of Scientific Notation
options(scipen=5)

# Opens the graphics device
png(filename="./plot5.png", height = 240, width = 680, units="px")

# load the ggplot2 library
library(ggplot2)

# Plot the graph of total emmisions against the year measured along with appropriate main title
qplot(year, Emissions, data = vehicleEmissionData, binwidth=2, geom=c("point", "smooth"), method="lm") + labs(title="Motor Vehicle Emission from Baltimore City") + geom_point(aes(color=year), size=4, alpha=1/2) + theme_bw(base_family="Times")

# Close the graphics device
dev.off()