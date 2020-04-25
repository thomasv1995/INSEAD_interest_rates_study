library(openxlsx)
library(zoo)
library(dplyr)

load.rates <- function(month, year,dir){
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
  #load excel data
  workbook <- loadWorkbook("./input_data/Interest_rates_US_monthly1919-2018_for_Arian&Matthijs.xlsx")
  data <- readWorkbook(workbook, sheet=2, colNames = TRUE)
  data$date<-  as.Date(data$date-25569)
  
  # main data frame in which we will store all avariables
  rates <- select(data, date, tcmnom_y10, tcmnom_y5, tcmnom_y3, tcmnom_y1)
  
  start.index <- which(substr(rates$date,1,7) == paste(year, "-",months$month_number[month.num], sep=""))
  rates <- rates[-(1:start.index-1),]
  colnames(rates) <- c('date', 'tcmnom_y10', 'tcmnom_y5','tcmnom_y3','tcmnom_y1')
  # check for any other Na's
  print(paste("Number of NA's:",sum(is.na(rates))))
  
  # get rates for each year
  rates.yearly<-month.to.year(rates)
  
  # load cpi csv file
  cpi <- read.csv('./input_data/CPIAUCSL.csv')
  # get the index of the first observation which happens in the month we specified
  start.index <- which(substr(cpi$DATE[1:12],6,7)==months$month_number[month.num])-1
  # get the index for the last cpi observation for the given month
  end.index <- which(substr(cpi$DATE[(nrow(cpi)-11):nrow(cpi)],6,7)==months$month_number[month.num]) + (nrow(cpi)-11)
  cpi <- cpi[-c(1:start.index, end.index:nrow(cpi)), ]
  
  #convert cpi to yearly data
  cpi.yearly <- month.to.year(cpi)
  # compute realized inflation (using log difference)and store it in cpi
  realized.inflation <- round(diff(log(cpi.yearly$CPIAUCSL))*100,2)
  cpi.yearly <- cpi.yearly[-1,]
  cpi.yearly$realized.inflation <- realized.inflation
  # since we do not have data for cpi after april 2019, get rid of the 2018 row in rates if month is after april
  # but keep it if month is before November since there is no observation in rates for November and 
  # December 2018 anyway
  if(month.num > 4 & month.num <11){
    rates.yearly <- rates.yearly[-nrow(rates.yearly),]
  }
  end.index= nrow(cpi.yearly)- nrow(rates.yearly)
  # store one-year-ahead realized inflation (from 1955 to 2019) in rates table
  rates.yearly$pi.realized <- cpi.yearly$realized.inflation[-(1:end.index)]
  #compute real interest rates 
  rates.yearly$r_y10 <- rates.yearly$tcmnom_y10 - rates.yearly$pi.realized
  rates.yearly$r_y5 <- rates.yearly$tcmnom_y5 - rates.yearly$pi.realized
  rates.yearly$r_y3 <- rates.yearly$tcmnom_y3 - rates.yearly$pi.realized
  rates.yearly$r_y1 <- rates.yearly$tcmnom_y1 - rates.yearly$pi.realized
  return(rates.yearly)
}  