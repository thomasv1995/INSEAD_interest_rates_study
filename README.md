# US Real Interest Rates Study
*Thomas Vermaelen*  

This study is part of the research paper "Learning from Interest Rates: Implications for Stock-Market Efficiency" by Matthijs Breugem, Adrian Buss &amp; Joel Peress (paper: https://www.carloalberto.org/wp-content/uploads/2019/01/BBP-LearnBondMarket-20190318.pdf). I evaluate different models for forecasting inflation in order to build multiple time series of US real interest rates that are computed using the forecasted inflation series, thus removing look-ahead bias. Furthermore, I the study the relationship between the US bond supply and real interest rates (Krishnamurthy study) to determine if bond supply is a good instrumental variable for studying the relationship between interest rates and price informativeness (a.k.a. stock market efficiency). The main objectives of this code are to visualize various times series for real interest rates that are computed based on different forecasting models, nominal interest rates (1-, 3-, 5-, 10-Y Treasury rates), timeframes (monthly vs annual time series) and reference months (for annual series). 

For better visualization of my results and learning about the respective the methodologies, associated RMarkdowns can be viewed using the following links:  
• https://rpubs.com/thomasv1995/609106 (Annual Interest Rates)  
• https://rpubs.com/thomasv1995/609108 (Monthly Interest Rates)    
• https://rpubs.com/thomasv1995/611130 (Krishnamurthy Study)

## Scripts  

• "Annual_December_Real_Interest_Rates.Rmd": evaluates forecasting models for yearly inflation and shows results for yearly real interest rates using December as the reference month. Also outputs the computed annual real interest rate time series as a csv file.   
• "Annual_March_Real_Interest_Rates.Rmd": same as above but using March as the reference month  
• "Annual_Real_Interest_Rates.R": R program which essentially performs the same routine as above except that the user is prompted for a reference month and starting year. This made it easy for professors Adrian Buss and Joël Peress to instantly get results for difference reference months  
• "Monthly_Real_Interest_Rates.Rmd": evaluates monthly inflation forecasting models and presents results. Outputs the monthly real interest rate time series as a csv  
• "Krishnamurthy_Study.Rmd": Using Krishnamurthy & Vissing-Jorgensen, 2012 as reference, I perform linear regression to study the relationship between US Treasury Supply and real interest rates. The ultimate goal for professors Adrian Buss & Jöel Peress is to find a good instrumental variable (IV) to stud the relationship between real interest rates and stock price informativeness

