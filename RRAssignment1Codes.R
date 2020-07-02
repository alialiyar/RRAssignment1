rm(list=ls())
 
##check if the source file is loaded, if not, we download it and unzip the file:
if(!file.exists("activity.csv")) {
  tempfile <- tempfile()
  download.file("http://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip",destfile = tempfile)
  unzip(tempfile)
  unlink(tempfile)
}

#load data
activity <- read.csv("activity.csv")

## inspecting the data set. 
summary(activity)
str(activity)

## total number of steps per day
activity_steps_day <- aggregate(steps ~ date, data = activity, FUN = sum, na.rm = TRUE)

## histogram of total no of steps per day
hist(activity_steps_day$steps, xlab = "Steps per Day", main = "Total number of steps taken per day", col = "wheat")

## mean and median of total speps per day
mean_steps <- mean(activity_steps_day$steps)
median_steps <- median(activity_steps_day$steps)
#we set a normal number format to display the results
mean_steps <- format(mean_steps,digits=1)
median_steps <- format(median_steps,digits=1)

print(mean_steps)

print(median_steps)


