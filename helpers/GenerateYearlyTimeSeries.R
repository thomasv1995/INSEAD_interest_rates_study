generate.yearly.ts <- function(i, r, start.year, end.year, title.rate, r.ar1=NULL, r.ses=NULL){
  i.ts <- ts(i, start=c(start.year), end =c(end.year),  frequency =1)
  r.ts <- ts(r, start=c(start.year), end =c(end.year),  frequency =1)
  if(!is.null(r.ar1)){
    r.ar1.ts <- ts(r.ar1, start =c(start.year), end=c(end.year), freq =1)
    r.ses.ts <- ts(r.ses, start =c(start.year), end=c(end.year), freq =1)
  }
  plot(i.ts, col='red', xlim=c(start.year, end.year),xaxs='i', ylim=c(min(r), max(i)), 
  ylab= 'Percent', main=paste(title.rate, " Nominal and Real U.S. Treasury Rates (",start.year, " to ", end.year,")", sep=""))
  lines(r.ts, col='blue', lty =2)
  if(!is.null(r.ar1)){
    lines(r.ar1.ts, col='green', lwd=2)
    lines(r.ses.ts, col = 'purple', lty =2, lwd=2)
  }
  abline(c(0,0))
  grid(col='lightgrey')
  if(is.null(r.ar1)){
    legend('topright', c('Nominal Rate', 'Real Rate (Actual)'), col = c('Red', 'Blue'), lty=c(1,2), cex =0.85)
  } else{
    legend('topright', c('Nominal Rate', 'Real Rate (Actual)', 'Real Rate (Ar(1))', 'Real Rate (SES)'), col = c('Red', 'Blue', 'Green', 'Purple'), lty=c(1,3,1,2), lwd =c(1,1,2,2), cex =1)
  }
}

