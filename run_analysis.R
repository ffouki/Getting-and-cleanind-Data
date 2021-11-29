##download data

rm(list = ls())

library(data.table)
library(dplyr)

if(!file.exists("./data")){dir.create("./data")}
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataUrl,destfile="./data/UCI_HAR_DATASET.zip",method="curl")


unzip(zipfile="./data/UCI_HAR_DATASET.zip",exdir="./data")

file.remove("./data/UCI_HAR_DATASET.zip")

#Read all files

inputFolder <- paste(getwd(), 'data','UCI HAR Dataset', sep = "/")

files_list<- list.files(inputFolder, recursive= TRUE)

#test files
subject_test <- read.table("data/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
Features_test <- read.table("data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
Activity_test <- read.table("data/UCI HAR Dataset/test/y_test.txt", col.names = "Act_code")

#train files
subject_train <- read.table("data/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
Features_train <- read.table("data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
Activity_train <- read.table("data/UCI HAR Dataset/train/y_train.txt", col.names = "Act_code")

# 1: Merge the training and the test sets to create one data set

Subject <- rbind(subject_train, subject_test)
Activity<- rbind(Activity_train, Activity_test)
Features<- rbind(Features_train, Features_test)

Act_code <- read.table("data/UCI HAR Dataset/activity_labels.txt", col.names = c("Act_code", "activity"))

FeaturesNames <- read.table("data/UCI HAR Dataset/features.txt", header = FALSE)

names(Features)<- FeaturesNames$V2

Final_data <- cbind(Features, Activity, Subject)

# 2: Extracts only the measurements on the mean and standard deviation for each measurement.

Final <- Final_data %>% select( Act_code, subject, contains("mean"), contains("std"))

#Step 3: Uses descriptive activity names to name the activities in the data set.

Final$Act_code <- Act_code[Final$Act_code, 2]

# 4: Appropriately labels the data set with descriptive variable names.

names(Final) <- gsub("^t", "time", names(Final))
names(Final) <- gsub("^f", "frequency", names(Final))
names(Final) <- gsub("Acc", "Accelometer", names(Final))
names(Final) <-gsub("BodyBody", "Body", names(Final))
names(Final) <- gsub("Gyro", "Gyroscope", names(Final))
names(Final) <-gsub("Mag", "Magnitude", names(Final))
names(Final) <- gsub("Freq", "Frequency", names(Final))

names(Final)

# 5: From the data set in step 4, creates a second, 
#independent tidy data set with the average of each variable for each activity and each subject.


Final_tidy <- Final %>%
  group_by(subject,Act_code) %>% summarise_all(mean)

write.table(Final_tidy, "Final_tidy.txt", row.name=FALSE)


