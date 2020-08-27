# US Real Interest Rates Study
*Thomas Vermaelen*  
This study is part of the research paper "Learning from Interest Rates: Implications for Stock-Market Efficiency" by Matthijs Breugem, Adrian Buss &amp; Joel Peress (paper: https://www.carloalberto.org/wp-content/uploads/2019/01/BBP-LearnBondMarket-20190318.pdf). I evaluate different models for forecasting inflation in order to build multiple time series of US real interest rates that are computed using the forecasted inflation series. Furthermore, I the study the relationship between the US bond supply and real interest rates (Krishnamurthy study) to determine if bond supply is a good instrumental variable for studying the relationship between interest rates and price informativeness (a.k.a. stock market efficiency). The main objectives of this code are to visualize various times series for real interest rates that are computed based on different forecasting models, nominal interest rates (1-, 3-, 5-, 10-Y Treasury rates), timeframes (monthly vs annual) and reference months (for annual series). 

For better visualization of my results and learning about the respective the methodologies, associated RMarkdowns can be viewed using the following links:  
• https://rpubs.com/thomasv1995/609108 (Monthly Interest Rates)  
• https://rpubs.com/thomasv1995/609106 (Annual Interest Rates)   
• https://rpubs.com/thomasv1995/611130 (Krishnamurthy Study)

## Scripts  

"Annual_December_Real_Interest_Rates.Rmd": evaluates forecasting models for inflation and shows results for annual real interest rates using December as the reference month. 
"Annual_March_Real_Interest_Rates.Rmd": same as above but using March as the reference month. 

