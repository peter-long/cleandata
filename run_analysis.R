# Getting and Cleaning Data Project - Peter Long
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Load Packages and get the Data
library(dplyr)


# Download and unzip the dataset once:
filename <- "uci-har-dataset.zip"
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# Read in Features, Activities, Subjects, and Lables
featTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
featTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
actTrain <- read.table("./UCI HAR Dataset/train/Y_train.txt")
actTest <- read.table("./UCI HAR Dataset/test/Y_test.txt")
subjTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjTest  <- read.table("./UCI HAR Dataset/test/subject_test.txt")
actLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
featNames  <- read.table("./UCI HAR Dataset/features.txt")

# 1. Merge the training and test sets to create one data set

featData <- rbind(featTrain, featTest) ; names(featData) <- featNames$V2
actData <- rbind(actTrain, actTest) ; names(actData) <- "activity"
subjData <- rbind(subjTrain, subjTest) ; names(subjData)   <- "subject"

allData <- cbind(featData, actData, subjData)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

keepCols <- grepl("subject|activity|mean|std", colnames(allData))
allData <- allData[, keepCols]

# 3. Uses descriptive activity names to name the activities in the data set

allData$activity <- actLabels[allData$activity, 2]

# 4. Appropriately label the data set with descriptive variable names

names(allData) <-gsub("^t", "time", names(allData))
names(allData) <-gsub("^f", "frequency", names(allData))
names(allData) <-gsub("Acc", "Accelerometer", names(allData))
names(allData) <-gsub("Gyro", "Gyroscope", names(allData))
names(allData) <-gsub("Mag", "Magnitude", names(allData))
names(allData) <-gsub("BodyBody", "Body", names(allData))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.#

dataMeans <- allData %>% group_by(subject, activity) %>% summarise_all(funs(mean))
write.table(dataMeans, "tidy_data.txt", row.names = FALSE,quote = FALSE)

