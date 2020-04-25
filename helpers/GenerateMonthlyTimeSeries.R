generate.monthly.ts <- function(i, r, start.year,start.month, end.year,end.month, title.rate,title.start.month,title.end.month, r.ar1=NULL, r.ses=NULL){
  i.ts <- ts(i, start=c(start.year, start.month), end =c(end.year, end.month),  frequency =12)
  r.ts <- ts(r, start=c(start.year, start.month), end =c(end.year, end.month),  frequency =12)
  if(!is.null(r.ar1)){
    r.ar1.ts <- ts(r.ar1, start =c(start.year, start.month), end=c(end.year, end.month), freq =12)
    r.ses.ts <- ts(r.ses, start =c(start.year), end=c(end.year, end.month), freq =12)
  }
  plot(i.ts, col='red',xaxs='i', ylim=c(min(r), max(i)), 
       ylab= 'Percent', main=paste(title.rate, " Nominal and Real U.S. Treasury Rates (",title.start.month, " ",start.year, " - ",title.end.month, " ", end.year,")", sep=""))
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