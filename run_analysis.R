install.packages("reshape2")

library(reshape2)

## Name of file data
filename <- "data.zip"

##Download and unzip the dataset
if(!file.exists(filename)){
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(url, filename, method = "curl")
}
if (!file.exists("UCI HAR Dataset")){
        unzip(filename)
}

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extact data on mean and standard deviation

searchFeatures <- grep(".*mean.*|.*std.*", features[,2])
searchFeatures.names <- features[searchFeatures,2]
searchFeatures.names = gsub('-mean', 'Mean', searchFeatures.names)
searchFeatures.names = gsub('-std', 'Std', searchFeatures.names)
searchFeatures.names <- gsub('[-()]', '', searchFeatures.names)

train <- read.table("UCI HAR Dataset/train/X_train.txt")[searchFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[searchFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets and add labels
Data <- rbind(train, test)
colnames(Data) <- c("subject", "activity", searchFeatures.names)

# Turn activities & subjects into factors
Data$activity <- factor(Data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
Data$subject <- as.factor(Data$subject)

Data.melted <- melt(Data, id = c("subject", "activity"))
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)

write.table(Data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)