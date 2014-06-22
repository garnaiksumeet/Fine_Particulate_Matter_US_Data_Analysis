## This script explores the data set of Fine Particulate Matter of US from 1999 to 2008 and
## tries to establish a comparision between the trend of the emmision of particulate matter by Motor Vehicles
## of Baltimore City, Maryland and Los Angeles, California with time.

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

# Subset the data of only Los Angeles, California and set the row.names to NULL
losAngelesData <- PED[PED[, "fips"] == "06037", ]
row.names(baltimoreData) <- NULL

# subsetting of the Particulate emission data set based on the exhaustive list of the Motor Vehicle
# SCC code list for Baltimore
vehicleEmissionDataBaltimore <- subset(baltimoreData, SCC %in% codeList)
row.names(vehicleEmissionDataBaltimore) <- NULL

# subsetting of the Particulate emission data set based on the exhaustive list of the Motor Vehicle
# SCC code list for Baltimore
vehicleEmissionDataLosAngeles <- subset(losAngelesData, SCC %in% codeList)
row.names(vehicleEmissionDataLosAngeles) <- NULL

# Computes the data required to establish a relation for Baltimore City
totalEmissionsBaltimore <- tapply(vehicleEmissionDataBaltimore$Emissions, vehicleEmissionDataBaltimore$year, FUN = sum)

# Computes the data required to establish a relation for Baltimore City
totalEmissionsLosAngeles <- tapply(vehicleEmissionDataLosAngeles$Emissions, vehicleEmissionDataLosAngeles$year, FUN = sum)

## we convert both the sums into data data frames and merge them to obtain the data into a single data frame and
## plot them to compare the Vehicle Emissions

# Conversion of the sum of emissions of Baltimore City into data.frame
baltimoreDataFrame <- as.data.frame(totalEmissionsBaltimore)
baltimoreDataFrame <- cbind(rownames(baltimoreDataFrame), baltimoreDataFrame)
names(baltimoreDataFrame) <- c("Year", "TotalEmissionsBaltimore")
row.names(baltimoreDataFrame) <- NULL

# Conversion of the sum of emissions of Los Angeles into data.frame
losAngelesDataFrame <- as.data.frame(totalEmissionsLosAngeles)
losAngelesDataFrame <- cbind(rownames(losAngelesDataFrame), losAngelesDataFrame)
names(losAngelesDataFrame) <- c("Year", "TotalEmissionsLosAngeles")
row.names(losAngelesDataFrame) <- NULL

# merging of data frames of both the cities into a single data frame
mergedData <- merge(baltimoreDataFrame, losAngelesDataFrame)

# conversion of the data frame into a matrix to be able to plot in base plotting system
mergedDataMatrix <- as.matrix(mergedData[-1])
rownames(mergedDataMatrix) <- mergedData[, 1]

# Set the enviroment to represent the data in the plots in decimal format
# instead of Scientific Notation
options(scipen=5)

# Opens the graphics device
png(filename="./plot6.png", height = 680, width = 560, units="px")

# Plot the graph of total emmisions against the year measured along with appropriate main title
barplot(t(mergedDataMatrix), col=c("red", "orange"), space=0.5, las = 1, main="Total Emission for Baltimore City and Los Angeles", xlab="Year", ylab="Emissions from Motor Vehicles")
legend("topright", legend=c("Baltimore City", "Los Angeles"), fill=c("red", "orange"))

# Close the graphics device
dev.off()