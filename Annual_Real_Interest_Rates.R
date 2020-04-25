library(openxlsx)
library(zoo)
library(plyr)
library(forecast)
library(tseries)
library(urca)
library(dplyr)

# Set working directory to the folder where I saved my code 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
dir= getwd()
source("./helpers/LoadRates.R")
exit <- function() {
  .Internal(.invokeRestart(list(NULL, NULL), NULL))
}  
############## Prompt user for month ###################
month = "none"
months <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")
while(!(month %in% months)){
  month <- tolower(readline(prompt="Enter Month name in full (press 'exit' to quit): "))
  if(!(month %in% months) & month !="exit"){
    print(paste(month, " is not a correct month. Please try again.", sep=""))
  }
  if(month =="exit"){
    exit()
  }
}

############## Prompt user for year ###################
start.year =-1
while(start.year >2016 | start.year <1953){
  start.year <- readline(prompt="Enter Start Year between 1953 and 2016 included (press 'exit' to quit): ")
  if(tolower(start.year) =="exit"){
    exit()
  }else {
    start.year = as.numeric(start.year)
    if(start.year >2016 | start.year <1953){
      print(paste(start.year, " is not a correct year. Please try again.", sep=""))
    }
    if(start.year ==1953 & (month=="january" | month =="february" | month== "march")){
      print("Data in 1953 is only available starting in April")
      start.year=-1
    }
  }
}                     

rates.yearly <- load.rates(month, start.year, dir)

## Root Mean Squared error function
rmse <- function(y, pred){
  return(sqrt(mean((y-pred)^2)))
}  

source("./helpers/GenerateYearlyTimeSeries.R")
#generate time series for 10-Y rates, plot them
end.year = as.numeric(substr(rates.yearly$date[nrow(rates.yearly)],1,4))
generate.yearly.ts(rates.yearly$tcmnom_y10, rates.yearly$r_y10, start.year, end.year, paste(month,"10-Year"))

#generate time series for 5-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y5, rates.yearly$r_y5, start.year, end.year, paste(month,"5-Year"))

#generate time series for 3-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y3, rates.yearly$r_y3, start.year, end.year, paste(month,"3-Year"))

#generate time series for 1-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y1, rates.yearly$r_y1, start.year, end.year, paste(month,"1-Year"))

source("./helpers/LoadCPI.R")
cpi.yearly = load.cpi(month, year, dir)
#plot inflation
pi.ts <- ts(cpi.yearly$realized.inflation,start=c(1948), end =c(2019),  frequency =1 )
plot(pi.ts, main = 'March Inflation at year = Y (1948 to 2019)', ylab='Percent', xaxs ='i')
abline(c(0,0))
grid(col='lightgrey')

Acf(pi.ts, main = 'Autocorrelations of Inflation')

Pacf(pi.ts, main = ' Partial Autocorrelations of Inflation')
### Dickey-Fuller test
summary(ur.df(pi.ts, type='none',selectlags = 'BIC'))
#select ARIMA model based on Bayesian Information Criterion
bic.mod <- auto.arima(pi.ts, d=0, ic ='bic', seasonal =FALSE)
summary(bic.mod)

# fit AR(1) model to full inflation series (1948-2019)
ar1.mod <- Arima(pi.ts, order=c(1,0,0))
#now fit SES
ses.mod <- ets(pi.ts, model ='ANN', alpha =0.2)
### Show RMSE's for both
print('RMSE for AR(1):')
rmse(pi.ts, fitted(ar1.mod))
print('RMSE for SES:')
rmse(pi.ts, fitted(ses.mod))
#perform Diebold-Mariano test on both models
dm.test(ar1.mod$residuals, ses.mod$residuals)


#Plot AR(1) and SES estimates
title = paste("Estimated Models of",month, "Inflation (1948 to 2019)")
plot(pi.ts, ylab ='Percent', main = title, xaxs='i')
lines(fitted(ar1.mod), col ='blue', lwd=2)
lines(fitted(ses.mod), col='red', lwd=2, lty=2)
legend('topright', c('AR(1)', 'SES'), col=c('blue', 'red'), lty=c(1,2), lwd=2, cex =0.85)
abline(c(0,0))
grid(col='lightgrey')


###### AR(1) vs SES forecasting using fixed partitioning 
# set forecast horizon to 30
nValid <- 30
#training set: 1948 to 1989
train <-  window(pi.ts, end=c(1989), freq =1)
#validation set: 1990 to 2019
valid <- window(pi.ts, start=c(1990), freq =1)
# AR(1) on training set
ar1.train <- Arima(train, order=c(1,0,0))
# forecast values until 2019
ar1.fixed <- forecast(ar1.train, h=nValid, level =95)

# SES on train
ses.train <- ets(train, model = 'ANN', alpha =0.2)
#forecast 
ses.fixed <- forecast(ses.train, h=nValid)

### print RMSE's and results of Diebold-Mariano Test
print('RMSE of AR(1) forecast:')
rmse(valid, ar1.fixed$mean)
print('RMSE of SES forecast:')
rmse(valid, ses.fixed$mean)
dm.test(ar1.fixed$residuals, ses.fixed$residuals)

### plot fixed forecasts
plot(pi.ts, ylab='Percent', main = '30-year-ahead Fcast of Inflation using Fixed Part. (1990-2019)', xaxs= 'i')
abline(v=c(1989,0), lty=2)
abline(c(0,0))
grid(col = 'lightgrey')
text(1986, 12, 'Train', cex =1.25)
text(1996, 12, 'Validation', cex =1.25)
lines(valid, col='black')
lines(ar1.fixed$mean, col = 'blue', lwd =2)
lines(ses.fixed$mean, col= 'red', lty =2 ,lwd=2)
legend('topright', c('AR(1)', 'SES'), col=c('blue', 'red'), lty=c(1,2),lwd=2, cex =0.85)

######## Ar(1) vs SES forecasts using roll-forward partioning 
#####AR(1)
#set forecast horizon 
n <- nrow(rates.yearly)
# set validation window
valid.roll <- window(pi.ts, start = c(start.year+1), end = c(start.year+n), freq =1) 
# initialize vector which will contains forecasts
ar1.roll <- rep(0,n)

#perform forecasts using roll-forward partitioning 
for (i in 0:(n-1)) {
  # move training window along one point each time starting in year 1962
  train.temp <- window(pi.ts, end=c(start.year+i), freq =1)
  # train on recursive window
  ar1.model <- Arima(train.temp,order=c(1,0,0))
  #one-step-ahead forecast
  onestep <- forecast(ar1.model,h=1, level=95)
  # store fcast value
  ar1.roll[i+1] <- onestep$mean
}

## SES forecasts 
ses.roll <- rep(0,n)

# roll-forward for SES
for (i in 0:(n-1)) {
  # move training window along one point each time start in year 1962
  train.temp <- window(pi.ts, end=c(start.year+i))
  # train on recursive window
  ses.model <- ets(train.temp,model ='ANN', alpha =0.2)
  #one-step-ahead forecast
  onestep <- forecast(ses.model,h=1, level=95)
  # forecast is the i+1 element of the fitted model
  ses.roll[i+1] <- onestep$mean
}


### RMSE's and D-M test
print('RMSE for recursive AR(1)')
rmse(valid.roll, ar1.roll)
print('RMSE for recursive SES')
rmse(valid.roll, ses.roll)
dm.test(valid.roll-ar1.roll, valid.roll-ses.roll)

#plot roll-forward fcasts
ar1.roll.ts <- ts(ar1.roll,start=c(start.year+1),freq=1)
ses.roll.ts<- ts(ses.roll, start =c(start.year+1), freq =1)
title = paste('Fcasts of Inflation using Roll-Forward Part. (',start.year+1,'-',start.year+n,')', sep="")
plot(pi.ts, main = title, ylab='Percent', xaxs='i')
abline(v=c(start.year+1,0), lty=2)
abline(c(0,0))
grid(col ='lightgrey')
lines(ar1.roll.ts, col='blue', lwd=2)
lines(ses.roll.ts, col='red', lwd=2, lty =2)
legend('topright', c('AR(1)', 'SES'), col=c('blue', 'red'), lty=c(1,2), lwd=2, cex =0.85)

#Store real rates using fcasts of inflation
rates.yearly$r_y10.ar1.roll <-round(rates.yearly$tcmnom_y10 - ar1.roll,2) 
rates.yearly$r_y10.ses.roll <- round(rates.yearly$tcmnom_y10 - ses.roll,2)

rates.yearly$r_y5.ar1.roll <-round(rates.yearly$tcmnom_y5 - ar1.roll,2) 
rates.yearly$r_y5.ses.roll <- round(rates.yearly$tcmnom_y5 - ses.roll,2)

rates.yearly$r_y3.ar1.roll <-round(rates.yearly$tcmnom_y3 - ar1.roll,2) 
rates.yearly$r_y3.ses.roll <- round(rates.yearly$tcmnom_y3 - ses.roll,2)

rates.yearly$r_y1.ar1.roll <-round(rates.yearly$tcmnom_y1 - ar1.roll,2) 
rates.yearly$r_y1.ses.roll <- round(rates.yearly$tcmnom_y1 - ses.roll,2)

############################ Save real rates to file ###########################
if(!dir.exists("./output_data")){
  dir.create("./output_data")
}  
file.path = paste("./output_data/",month, 'RealRateFcastsYearly.csv', sep="")
write.csv(rates.yearly, file= file.path)

###generate time series for 10-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y10,rates.yearly$r_y10, start.year, end.year, paste(month, "10-Y"), rates.yearly$r_y10.ar1.roll,rates.yearly$r_y10.ses.roll )

###generate time series for 5-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y5,rates.yearly$r_y5, start.year, end.year, paste(month, "5-Y"), rates.yearly$r_y5.ar1.roll,rates.yearly$r_y5.ses.roll )

###generate time series for 3-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y3,rates.yearly$r_y3, start.year, end.year, paste(month, "3-Y"), rates.yearly$r_y3.ar1.roll,rates.yearly$r_y3.ses.roll )

###generate time series for 1-Y rates, plot them
generate.yearly.ts(rates.yearly$tcmnom_y1,rates.yearly$r_y1, start.year, end.year, paste(month, "1-Y"), rates.yearly$r_y1.ar1.roll,rates.yearly$r_y1.ses.roll)









