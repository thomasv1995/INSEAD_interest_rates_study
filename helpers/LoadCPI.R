library(openxlsx)
library(zoo)
library(dplyr)

load.cpi <- function(month, year,dir){
  setwd(dir)
  ### function to convert monthly to yearly data
  month.to.year <- function(dat){
    temp <- data.frame()
    i<-1
    while(i <= nrow(dat)){
      temp <- rbind(temp, dat[i,])
      i <- i+12
    }
    return(temp)
  }
  months <- as.data.frame(cbind(c("01","02","03","04","05","06","07","08","09","10","11","12"), c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")))
  colnames(months) <- c("month_number", "month")
  month.num <- which(months$month == tolower(month))
  # load cpi csv file
  cpi <- read.csv('./input_data/CPIAUCSL.csv')
  start.index <- which(substr(cpi$DATE[1:12],6,7)==months$month_number[month.num])-1
  end.index <- which(substr(cpi$DATE[(nrow(cpi)-11):nrow(cpi)],6,7)==months$month_number[month.num]) + (nrow(cpi)-11)
  cpi <- cpi[-c(1:start.index, end.index:nrow(cpi)), ]
  
  #convert cpi to yearly data
  cpi.yearly <- month.to.year(cpi)
  # compute realized inflation (using log difference)and store it in cpi
  realized.inflation <- round(diff(log(cpi.yearly$CPIAUCSL))*100,2)
  cpi.yearly <- cpi.yearly[-1,]
  cpi.yearly$realized.inflation <- realized.inflation
  
  return(cpi.yearly)
}  