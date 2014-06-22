## This script explores the data set of Fine Particulate Matter of US from 1999 to 2008 and
## tries to establish a trend of the emmision from coal with the time.

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

# Since the data values in SCC.Level.Three are not just listed as Coal but independently entered
# as Lignite, grep(ing) the SCC.Level.Three leads to a non-exhaustive list of all Coal source
# emissions, but we observe that Lignite is listed under souces with the column EI.Sector
# indicating Coal usage.
# Hence we take the following approach:

# grep the column EI.Sector to get a partial list of the Coal Sources
initialList <- unique(grep("Coal+", SCC$EI.Sector, value=T))

# grep the column SCC.Level.Three to get the souces excluding sources listed such as Lignite etc.
partialList <- unique(grep("Coal+", SCC$SCC.Level.Three, value=T))

# subset the SCC data set based on partialList
listData <- subset(SCC, SCC.Level.Three %in% partialList)

# grep the SCC.Level.One to find combustion related emissions
combustionList <- unique(grep("Combustion+", listData$SCC.Level.One, value=T))

# subset the already subsetted data set based on combustionList
tmpData <- subset(listData, SCC.Level.One %in% combustionList)

# append both the list to get an exhaustive list consisting all the Coal Sources
completeList <- c(unique(tmpData$EI.Sector), initialList)

# create a unique list of the exhaustive list
completeList <- unique(completeList)

# This is done inorder to exclude "Fuel Comb - Electric Generation - Other"
# This desicion is based on the observation that adding it brings a whole lot of other sources
# which are not Coal based. We can thus ignore the two other values that come under it rather than
# add it and increase the complicacies.
completeList <- c(completeList[1], completeList[3:5])

# final subsetting of the SCC data set
completeData <- subset(SCC, EI.Sector %in% completeList)

# an almost entirely exhaustive unique list of all SCC codes
codeList <- unique(completeData$SCC)

# a simple type data conversion
codeList <- as.character(codeList)

# subsetting of the Particulate emission data set based on the exhaustive list of the Coal Source
# SCC code list
coalEmissionData <- subset(PED, SCC %in% codeList)
row.names(coalEmissionData) <- NULL

# Computes the data required to establish a relation
totalEmissions <- tapply(coalEmissionData$Emissions, coalEmissionData$year, FUN = sum)

# Set the enviroment to represent the data in the plots in decimal format
# instead of Scientific Notation
options(scipen=5)

# Set the warnings of since we are changing the colors of the barplots
options(warn=-1)

# Opens the graphics device
png(filename="./plot4.png", height = 480, width = 480, units="px")

# Plot the graph of total emmisions against the year measured
barplot(totalEmissions, col="red")

# Set the appropriate labels and title
title(main="Total Emissions from Coal Comustion", xlab="Year", ylab="Total Emissions")

# Close the graphics device
dev.off()