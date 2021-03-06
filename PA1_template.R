## check if the source file is loaded, if not, download and unzip the file

if(!file.exists("activity.csv")) {
  tempfile <- tempfile()
  download.file("http://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip",destfile = tempfile)
  unzip(tempfile)
  unlink(tempfile)
}

## Loading and Processing Data 

activity <- read.csv("activity.csv")

## inspecting the data set 

summary(activity)
##      steps                date          interval     
##  Min.   :  0.00   2012-10-01:  288   Min.   :   0.0  
##  1st Qu.:  0.00   2012-10-02:  288   1st Qu.: 588.8  
##  Median :  0.00   2012-10-03:  288   Median :1177.5  
##  Mean   : 37.38   2012-10-04:  288   Mean   :1177.5  
##  3rd Qu.: 12.00   2012-10-05:  288   3rd Qu.:1766.2  
##  Max.   :806.00   2012-10-06:  288   Max.   :2355.0  
##  NA's   :2304     (Other)   :15840

str(activity)
## 'data.frame':    17568 obs. of  3 variables:
##  $ steps   : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ date    : Factor w/ 61 levels "2012-10-01","2012-10-02",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...

## total number of steps per day

activity_steps_day <- aggregate(steps ~ date, data = activity, FUN = sum, na.rm = TRUE)

## histogram of total no of steps per day

hist(activity_steps_day$steps, xlab = "Steps per Day", main = "Total number of steps taken per day", col = "wheat")

## mean and median of total speps per day

mean_steps <- mean(activity_steps_day$steps)
median_steps <- median(activity_steps_day$steps)
## mean steps per day: 10766
## median steps per day: 10765

## we set a normal number format to display the results

mean_steps <- format(mean_steps,digits=1)
median_steps <- format(median_steps,digits=1)
print(mean_steps)
print(median_steps)

## 5-minute time series plot(x-axis) and the number of steps taken )y-axis

activity_steps_mean <- aggregate(steps ~ interval, data = activity, FUN = mean, na.rm = TRUE)

## Plot

plot(activity_steps_mean$interval, activity_steps_mean$steps, type = "l", col = "green", xlab = "Intervals", ylab = "Total steps per interval", main = "Number of steps per interval (averaged) (NA removed)")

## maximum of steps on one given interval

max_steps <-max(activity_steps_mean$steps)

## for which interval are the numbers of steps per interval at the highest?

max_interval <- activity_steps_mean$interval[which(activity_steps_mean$steps == max_steps)]
max_steps <- round(max_steps, digits = 2)
print(max_steps)
print(max_interval)

## number of missing values in the dataset

sum(is.na(activity))
## [1] 2304

## subset general dataset with missing values only

missing_values <- subset(activity, is.na(steps))

## plot repartition, by intervals

par(mfrow = c(2,1), mar = c(2, 2, 1, 1))
hist(missing_values$interval, main="NAs repartition per interval")
hist(as.numeric(missing_values$date), main = "NAs repartion per date", breaks = 61)
hist(as.numeric(missing_values$date), main = "NAs repartion per date", breaks = 61)

## creating a new data frame with filled NA's

MeanStepsPerInterval <- tapply(activity$steps, activity$interval, mean, na.rm = TRUE)

## cut the 'activity' dataset in 2 parts (with and without NAs)

activity_NAs <- activity[is.na(activity$steps),]
activity_non_NAs <- activity[!is.na(activity$steps),]

## replace missing values in activity_NAs

activity_NAs$steps <- as.factor(activity_NAs$interval)
levels(activity_NAs$steps) <- MeanStepsPerInterval

## change the vector back as integer

levels(activity_NAs$steps) <- round(as.numeric(levels(activity_NAs$steps)))
activity_NAs$steps <- as.integer(as.vector(activity_NAs$steps))

## merge/rbind the two datasets together

imputed_activity <- rbind(activity_NAs, activity_non_NAs)

## Plotting parameters to place previous histogram and new one next to each other

par(mfrow = c(1,2))

## Plot again the histogram from the first part of the assignment

activity_steps_day <- aggregate(steps ~ date, data = activity, FUN = sum, na.rm = TRUE)
hist(activity_steps_day$steps, xlab = "Steps per Day", main = "NAs REMOVED - Total steps/day", col = "blue")

## Plot new histogram, with imputed missing values

imp_activity_steps_day <- aggregate(steps ~ date, data = imputed_activity, FUN = sum, na.rm = TRUE)
hist(imp_activity_steps_day$steps, xlab = "Steps per Day", main = "NAs IMPUTED - Total steps/day", col = "blue")
imp_mean_steps <- mean(imp_activity_steps_day$steps)
imp_median_steps <- median(imp_activity_steps_day$steps)

## we set a normal number format to display the results

imp_mean_steps <- format(imp_mean_steps,digits=1)
imp_median_steps <- format(imp_median_steps,digits=1)

## store the results in a dataframe

results_mean_median <- data.frame(c(mean_steps, median_steps), c(imp_mean_steps, imp_median_steps))
colnames(results_mean_median) <- c("NA removed", "Imputed NA values")
rownames(results_mean_median) <- c("mean", "median")


install.packages("xtable")
library(xtable)
xt <- xtable(results_mean_median)
print(xt, type  = "html")

## NA removed	Imputed NA values
## mean	10766	10766
## median	10765	10762


## elseif function to categorize Saturday and Sunday as factor level "weekend", all the rest as "weekday"

imputed_activity$dayType <- ifelse(weekdays(as.Date(imputed_activity$date)) == "Samstag" | weekdays(as.Date(imputed_activity$date)) == "Sonntag", "weekend", "weekday")

## transform dayType variable into factor

imputed_activity$dayType <- factor(imputed_activity$dayType)

## Aggregate a table showing mean steps for all intervals, acrlss week days and weekend days

steps_interval_dayType <- aggregate(steps ~ interval + dayType, data = imputed_activity, FUN = mean)

## verify new dataframe 

head(steps_interval_dayType)

## add descriptive variables

names(steps_interval_dayType) <- c("interval", "day_type", "mean_steps")

## plot with ggplot2

library(ggplot2)
plot <- ggplot(steps_interval_dayType, aes(interval, mean_steps))
plot + geom_line(color = "tan3") + facet_grid(day_type~.) + labs(x = "Intervals", y = "Average Steps", title = "Activity Patterns")