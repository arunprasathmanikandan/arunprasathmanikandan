
						* MGT6091 - ISSUES IN FINANCE *
					
				********* COURSEWORK GUIDE STATA DO FILE *********

/**
Disclaimer - these codes are written by Dr. Abongeh Tunyi for teaching purposes
only. There is no guarantee that the proposed procedure is error-free. 
There are simpler ways to achieve thesame results but the focus here is on
facilating student understanding of the process. Students are therefore 
required to rewrite the codes to suit their data and also encouraged to improve 
the codes as they get a better understanding of STATA.
**/

**there are issues with spellings, CAPS (lower and upper case) through out. It is your responsibility to fix them.



				********* ACTIVITY 1*********
				

//start with Datafile1

cls
clear
use Datafile1 
set more off  //set more off forces stata to run without breaking.
describe  //*what is in my dataset? Use "describe" command to see
browse

cls
clear
use Datafile2
describe  //*what is in my dataset? Use "describe" command to see
browse

// MERGE datasets - common variables are DSCD and YEAR

merge 1:1  // use merge 1:1  to merger files
keep if _merge==3  // why?
drop _merge

save Finaldata, replace // save the merged file. This will be your main file for analyses.


					********* ACTIVITY 2*********
					
					

**Exclude observations

drop if ...

**Generate variables as in reference study

*variable 1: dependent variable TARGET - dummy that takes 1 if a firm is a target

gen TARGET = TargetBidder == "Target"

*variable 2: Average excess return


//AER = AER is computed as a firm's average monthly excess return over the market (FTSE All Share) return
* You are given monthly RI for firms and the market. AER Can be computed from one month to another
* or using a loop.


/**
gen AR1 = ((RiM1-RiM0)/RiM0) - ((RmM1-RmM0)/RmM0)
gen AR2 = ((RiM2-RiM1)/RiM1) - ((RmM2-RmM1)/RmM1)
gen AR3 = ((RiM3-RiM2)/RiM2) - ((RmM3-RmM2)/RmM2)
gen AR4 = ((RiM4-RiM3)/RiM3) - ((RmM4-RmM3)/RmM3)
gen AR5 = ((RiM5-RiM4)/RiM4) - ((RmM5-RmM4)/RmM4)
gen AR6 = ((RiM6-RiM5)/RiM5) - ((RmM6-RmM5)/RmM5)
gen AR7 = ((RiM7-RiM6)/RiM6) - ((RmM7-RmM6)/RmM6)
gen AR8 = ((RiM8-RiM7)/RiM7) - ((RmM8-RmM7)/RmM7)
gen AR9 = ((RiM9-RiM8)/RiM8) - ((RmM9-RmM8)/RmM8)
gen AR10 = ((RiM10 -RiM9)/RiM9) - ((RmM10-RmM9)/RmM9)
gen AR11 = ((RiM11-RiM10)/RiM10) - ((RmM11-RmM10)/RmM10)
gen AR12 = ((RiM12-RiM11)/RiM11) - ((RmM12-RmM11)/RmM11)
**/

forvalues i = 1/12 {
	local j = `i'-1
	gen AR`i' = ((RiM`i'-RiM`j')/RiM`j') - ((RmM`i'-RmM`j')/RmM`j')
}
****
gen AER = ((1+AR1)*(1+AR2)*(1+AR3)* (1+AR4)*(1+AR5)*(1+AR6)*(1+AR7)*(1+AR8)*(1+AR9)*(1+AR10)*(1+AR11)*(1+AR12))-1

*Variable 3 - Profitability; ROCE, ROE ?


*Variable 4 - Tobins Q; TobinsQ


*Variable 5 - Industry disturbance dummy; IDDUMY


*Variable 6 - sales growth: SGRowth
*notice that you will need to use the lag command to identify/use lagged values.

sort Firmid Year
xtset id year
gen LSales = L.Sales



*Variable 7 - Liquidity LIQ


*Variable 8 - Growth Resource Mismatch dummy: GRUMMY


*Variable 9 - firm size: SIZE


*Variable 10 - Leverage; LEV


*Variable 11 - free cash flow: FCF


*Variable 12 - Tangible property; PPE


*Variable 13 - Firm Age; AGE


*Variable 14 - Herfindahl index; HHI


/** Rename the rest of your variables (Zscore, Rumours, repurchases, LIBORBOEBR 
FTSEChange, Msent, Volume, BLOCK ) which have been computed for you from Datafile2.
**/




/**
Lets create a global macro to avoid typing and retyping variable names. 
We use the global command - You can do without but this helps in automation
 & revision if needed. This means we can easily add or reduce variables in our analysis
I have selected a number of variables here including "ADAR TobinsQ Size FCF TANG AGE HHI"
For your project, you will have to decide which variables to use.
**/

global Variables AER TobinsQ Size FCF TANG AGE HHI

/**
To see what we have defined as "variables" we use the display command - 
- and put the funny quotation (` ') marks around "variable" so stata recognises
 this as a macro.
**/

display $Variables

describe $Variables

*notice that this is the same as typing;

describe AER TobinsQ Size FCF TANG AGE HHI

/**
Use "summarize" command to get an overview of key descriptive stats
**/

summarize $Variables


/**
Can do the same thing but for the two subgroups - targets and non targets. 
The grouping variable in TARGET. You need to sort the dataset by the TARGET variable first, 
then run the summarize command. The command for this is as follows;
**/

bysort TARGET: summarize $Variables

/**
You can also achieve this by doing the following;

bysort TARGET: summarize ADAR TobinsQ Size FCF TANG AGE HHI

At some point we might need to do some panel-type regression or...
other analysis so we need to tell stata that this is a panel dataset.

The unique id for firms and years are likely going to be stored as letters. 
You can use the "egen" (to generate a new variable)and the "group" command
to assign groups
**/

egen Firmid = group (DSCD)

egen Yearid = group (YEAR)

xtset Firmid Yearid

/**
We can now go on to specify the nature of our dataset. 
The "xtset" command tells stata that the cross-sectional variable identifier (X)
is the variable "Firmid" and the time series variable identifier (T) is "Yearid" 
**/

xtset.... 

/**
Outliers are always an issue and may bias your results. You might want to 
consider taking out outliers after looking at your descriptive statistics. 
Pay particular attention to the min and max numbers. 
If  these are unreasonable - winsorise. **/



* You can do it manually. E.g.,

bysort year: egen ROAp1 = pctile(FCF), p(1)
bysort year: egen ROAp99 = pctile(FCF), p(99)
replace ROA = ROAp1 if ROA < ROAp1
replace ROA = ROAp99 if ROA > ROAp1

** since you have to do this for several variables, you can use a (foreach) loop. 

/**
Taking care of outliers in the dataset with winsorise command "winsor2"
"cuts (1 99), replaces every value above below the 1st percentile and...
every value above the 99th percentile with the 1st and 99th percentile values
respectively. I have specified that I want to winsorise all variables ( `Variables') below
but this is not OK. You need to check descriptives and only winsorise
variables with likely outliers.
**/

winsor2 $Variables , cuts(1 99) by(year) replace  // you will need to install winsor2 first; ssc install winsor2

/**
After winsorising, you can check your descriptive stats again
to see whether you still have some outliers.

**/




bysort TARGET: summarize $Variables

/**
Altenatively, we can use "tabstat" to generate descriptive statistics for 
all firms in the sample, as follows;

The "///" below just allows us to continue our code on a new line.
**/

tabstat $Variables , statistics(count mean sd skewness min max median ) ///
		columns(statistics) format(%9.3f)

**for non targets (TARGET = 0)
tabstat $Variables if TARGET==0, ///
		statistics(count mean sd skewness min max median ) ///
		columns(statistics) format(%9.3f)

**for targets (TARGET = 1)
tabstat $Variables if TARGET==1, ///
		statistics(count mean sd skewness min max median ) ///
		columns(statistics) format(%9.3f)


/**
After looking at your descriptives- you can judge whether your data is ready
for further analysis. You can redo your descriptive stats analysis with t tests
and report the results, as in activity 4.

Make sure you spend some time cleaning and checking your data as your results 
are only as good as your data's integrity. 

Remember  "Gabbage in Gabbage out!"
**/


save Finaldata2, replace  // saving a clean dataset for further analyses



					********* ACTIVITY 3*********

cls
use Finaldata2, clear
set more off
xtset firmid yearid 

/** 
You can do t-tests using the following command "ttest". The ttest command will 
not take multiple variables (ADAR TobinsQ Size FCF TANG AGE HHI) 
so you can't use `Variables'
The command only allows you to test one variable at a time.
**/

ttest ADAR, by(TARGET)
ttest TobinsQ, by(TARGET)
ttest Size, by(TARGET)
ttest FCF, by(TARGET)
ttest TANG, by(TARGET)
ttest AGE, by(TARGET)
ttest HHI, by(TARGET)


** You can use a foreach loop above

/**
This is too time consuming if you have 20 variables so, there is an easy way!
Good commands to use for t-test are user written commands called "estpost" and 
"esttab". You will need to install them as follows: 

ssc install estpost
ssc install esttab

The above two lines will install the two commands on yr stata.
You can then use them as follows:
**/

estpost ttest `Variables' , by(TARGET)
esttab ., wide

/**
The following results vectors are saved in e():

        ** e(b)         mean difference
        * e(count)     number of observations
        * e(se)        standard error of difference
         * e(t)         t statistic
         * e(df_t)      degrees of freedom
        *  e(p_l)       lower one-sided p-value
        *  e(p)         two-sided p-value
         * e(p_u)       upper one-sided p-value
        *  e(N_1)       number of observations in group 1
        *  e(mu_1)      mean in group 1
        *  e(N_2)       number of observations in group 2
        *  e(mu_2)      mean in group 2
**/
		
		
		
		
		********* ACTIVITY 4*********
		
// - Regression analysis

*set more off forces stata to run without breaking.
set more off 

/**
You will need to install a user written command called "outreg2". 
This exports your regression results and presents them in a manner similar to
those in journal articles. You can install "outreg2" as follows:
 
ssc install outreg2

Before performing your regression you might need to check for multicollinearity 
by generating a correlation matrix, as follows;
**/

pwcorr `Variables', star(0.001) sig 



/** 
Look at the correlation coefficients and see whether some of your variables
are highly correlated. Correlation coefficients > 0.3 or so (depending on
the study) can be cause for concern. If high correlations, you can decide to
drop some variables - but review the theory.

If all looks good, we can now develop our regression model. Always a good idea
start with a simple pooled regression model. Given a panel set, you can 
generate robust standard errors, or can cluster standard errors by year (YearCl)
or firm (FirmCl) or even a combination of the two.

You might also want to rethink what variables to put in your regression model.
Do you need all? 
Do you need more? 
Do you want to develop multiple models?

Use the literature to inform your choice.

Consider using "local" command to develop multi-level models.

Post-regression, use the outreg command to generates a word file with your 
regression results. If you have not installed it, do so as follows;

ssc install outreg2
**/


/**
recall Variables is the following list "ADAR TobinsQ Size FCF TANG AGE HHI"
We achieved this using the following command

global Variables ADAR TobinsQ Size FCF TANG AGE HHI

So lets define other lists so we can do regressions with different variables in
our model.
**/

global Variables1 ADAR TobinsQ Size FCF TANG AGE 
global Variables2 ADAR TobinsQ Size FCF  
global Variables3 ADAR TobinsQ 

/**

We have now generated new lists which we can use in our regressions. We use the 
logit regression command "logit".

You can use "quietly" to surpress the results not. I have used "quietly" in all
but the first model so we don't generate too much results which might be hard
to follow.
I have clustered by firm - consider clustering by year etc
**/

set more off

logit TARGET $Variables3, vce(cluster FirmCL)
outreg2 using myreg1.doc, replace ctitle(Model1)pvalue dec(3)

quietly logit TARGET $Variables2, vce(cluster FirmCL)
outreg2 using myreg1.doc, append ctitle(Model2)pvalue dec(3)

quietly logit TARGET $Variables1, vce(cluster FirmCL)
outreg2 using myreg1.doc, append ctitle(Model3)pvalue dec(3)

quietly logit TARGET $Variables, vce(cluster FirmCL)
outreg2 using myreg1.doc, append ctitle(Model4)pvalue dec(3)

*Panel logit fixed effects*
quietly xtlogit TARGET $Variables, fe
outreg2 using myreg1.doc, append ctitle(Panel)pvalue dec(3)


/**
If you check in the folder where your do-file is saved, you will see a word 
document named "myreg1". Your results should be in this word document.

**/

				********* ACTIVITY 6*********
				
				
				
// Predicting targets out-of-sample & model evaluation

/**
Here, you need to run recursive regressions for different periods and compute 
takeover probabilities one year ahead.
That is we want to use data from 1995-2004 to compute model parameters. 
Then use data from 2005 to estimate takeover likelihood, out-of-sample.
Then again use data from 1995-2005 to generate parameters which will then be
used to compute takeover likelihood for firms in 2006, and so forth.

You will need to decide which of your models (Model1, Model 2, Model3, Model4, 
panel)to use in this activity. 

The "predict" command (augmented with the "if" condition) uses the generated 
coefficients to estimate the probability in the next year based on next years'
data.

You can do the analysis quietly
**/

quietly {
logit TARGET `Variables' if YEAR <2005
predict P2005 if YEAR == 2005

logit TARGET `Variables' if YEAR <2006
predict P2006 if YEAR == 2006

logit TARGET `Variables' if YEAR <2007
predict P2007 if YEAR == 2007

logit TARGET `Variables' if YEAR <2008
predict P2008 if YEAR == 2008

logit TARGET `Variables' if YEAR <2009
predict P2009 if YEAR == 2009
}

*** we can use a loop to do same - easier


/**
We have now generated some five new variables P2005 to P2009, 
which are out-of-sample takeover probabilities, for the firms in our sample,
for 2005 to 2009.

The problem is that these are in five different columns as five different 
variables. We can now summarise this into 1 variable called "prob" using the
"rowtotal function.

The function simply adds up everything in a row across the selected five columns
P2005 to P2009
**/

egen Prob = rowtotal(P2005 P2006 P2007 P2008 P2009) 


/**
We have computed probabilities which lie between 0.000 and 1.000,
but the question is what cut-off should we use to determine whether a firm's
takeover likelihood is high enough for it to be considered a target.

A simple methodology used across several studies including the 
Danbolt, Siganos & Tunyi (2016) paper is to rank their takeover liklihood and
then to consider the quintile (20%) of firms with the highest takeover
likilihood as the portfolio of predicted targets.

So, for a start
Using computed takeover probabilities rank firms in QUINTILES. 
Assume that firms in quintile 5 (20% of firms with highest takeover probability)
are predicted targets.

The percentile function ("xtile") can be used to rank firms and create quintiles
Here we specify using "nq" - that we want 5 groups - quintiles. If we want 10 
groups we will use -nq(10)
**/


quietly {
xtile T2005 = P2005 if YEAR==2005, nq(5)
xtile T2006 = P2006 if YEAR==2006, nq(5)
xtile T2007 = P2007 if YEAR==2007, nq(5)
xtile T2008 = P2008 if YEAR==2008, nq(5)
xtile T2009 = P2009 if YEAR==2009, nq(5)
}

/**
Again, results will appear in 5 different columns so you will need to summarise
these into one column and name this column, for example, Quintile.
The results will show you what quintile (1 to 5 or Q1 to Q5) each firmyear 
observation falls in.
**/

egen Quintile = rowtotal( T2005 T2006 T2007 T2008 T2009) 

*A more sophisticated way to do the above two steps is to use loops.

generate PNull =.

qui forvalues i = 2005(1)2009 {
	logit TNT `Var1' if Year < `i'
	predict temp if Year == `i'
	replace Prob2 = temp if Year == `i'
	drop temp
}

egen Quintile2 = xtile(Prob2), by(Year) nq(5)

/**
Is this model any good in predicting takeover targets?

We want to see how good our model is in predicting targets. 

We will be focusing on quintile 5 (Q5) only. If our model is perfect, 
all firms in Q5 should receive a bid. That is, if you look at the firms in Q5, 
all should have "1" as the value of their TARGET variable.

We need to check how many actually do. Many ways to do this.
You can, for example, 
count abc if Target == 1 & Quintile ==5 ,to obtain # of targets in Q5. 

But this just tells you how many true predictions you have made.

You can then compute Type II error
count abc if Target == 0 & Quintile ==5 ,to obtain # of non-targets in Q5.

The sum of the two will tell you the total # observations in Q5
 
A good measure of predictive performance is "target concentration ratio". This
is calculated as
TCR = actual number of targets in Q5 as a percentage of all firms in Q5
TCR = Targets in Q5/#observations in Q5

The higher the ratio, the better your model is, at predicting targets.

Ideally, you want to do this analysis by year -as model performance could vary
over time.
**/

tabstat TARGET if YEAR ==2005 & Quintile==5, stat (sum count)

/**
if you divide sum by count you get target concentration i.e.,
Target concentration = sum/count
You can do the same analysis for all years of prediction
**/

tabstat TARGET if YEAR ==2006 & Quintile==5, stat (sum count)
tabstat TARGET if YEAR ==2007 & Quintile==5, stat (sum count)
tabstat TARGET if YEAR ==2008 & Quintile==5, stat (sum count)
tabstat TARGET if YEAR ==2009 & Quintile==5, stat (sum count)

*alternatively

tabstat TARGET if Quintile==5, by (YEAR) stat (sum count)

/** 
As above, you can also use "tabstat" with a qualifier -by- so you don't 
have to repeat the command for each year
**/

bysort YEAR: egen Rankings = rank (-Prob)

save investmentdata, replace  // save the data so we can use in new analyses


    ********* ACTIVITY 6, 7*********

/** 
You will need to identify the 10 firms with highest takeover likelihood 
for each year. 

Step 1 - Rank firms in each year by takeover probability. -Prob allows reverse 
ranking where firm with highest takeover likelihood is given a rank of 1.

If you find that some ranks are missing due to ties you could modify your 
command as follows:
bysort YEAR: egen Rankings = rank (-Prob), unique
**/

cls
use investmentdata, clear


* to list the top 10 firms (DSCD - Datastream Codes) each year.

by YEAR: list DSCD Rankings if Rankings < 11 


drop if Rankings > 10 


/// When only investing in top 10 firms.

** drop if PNullQ <5 // to invest in all companies in Q5. Here, you can also perform other screenings, e.g., for bankruptcy

rename July1 P_0
rename August P_1
rename September P_2
rename October P_3
rename November P_4
rename December P_5
rename January P_6
rename February P_7
rename March P_8
rename April P_9
rename May P_10
rename June P_11
rename July P_12

forvalues i = 1/12 {
	local j = `i'-1
	gen Return_`i' = (P_`i'- P_`j')/P_`j'
	}

global Returns Return_1 Return_2 Return_3 Return_4 Return_5 Return_6 Return_7 Return_8 Return_9 Return_10 Return_11 Return_12

collapse (mean) $Returns, by(YEAR) // calculates the average monthly returns of our portfolio for each year.

reshape long Return_, i(YEAR) j(Month_number) // where month_number 1 is July. Here "i" is the identifier or cross-sectional variable, and "j" is the time-series variable

* Take a look at the third database (Datafile3) which we want to merge with this dataset. It has "Year" and "Month" which we will use to match. So we rename accordingly.

rename YEAR Year
rename Return_ Return

gen Month = ""
replace Month = "July" if Month_number==1
replace Month = "August" if Month_number==2
replace Month = "September" if Month_number==3
replace Month = "October" if Month_number==4
replace Month = "November" if Month_number==5
replace Month = "December" if Month_number==6
replace Month = "January" if Month_number==7
replace Month = "February" if Month_number==8
replace Month = "March" if Month_number==9
replace Month = "April" if Month_number==10
replace Month = "May" if Month_number==11
replace Month = "June" if Month_number==12

drop Month_number

order Year Month Return
save PortfolioReturns, replace


			********* ACTIVITY 8 ****************
clear
use PortfolioReturns
merge 1:1 Year Month using Datafile3
keep if _merge == 3 // drop the unmerged
drop _merge


gen RiRf = Return - rf

reg RiRf rmrf, vce (robust) // CAPM with Huber White's Standard errors
outreg2 using Alpha.doc, replace ctitle(CAPM)pvalue dec(3)

reg RiRf rmrf smb hml , vce (robust) //FF3F
outreg2 using Alpha.doc, append ctitle(FF3F)pvalue dec(3)

reg RiRf rmrf smb hml umd, vce (robust) // C4F 
outreg2 using Alpha.doc, append ctitle(C4F)pvalue dec(3)


			********** Extra work *************
			
			


/** The analysis section of the project makes up 40% of your mark. Hence, you will need to do more than the minimum requirement if you want to earn a high mark. Other analyses that can be done:

Test whether industry-adjusted ratios can help you to better predict targets.
Test whether industry-based models are more optimal (better) in prediction.
Test whether your definition of industry matters i.e., how you have identified industries.
Test whether models perform better, or worse under certain market conditions; e.g., market booms, financial crises
Test whether the size of the prediction portfolio matters i.e., whether performance is better when you have larger or smaller portfolios.
Test whether small (investing in only a few predicted targets) and large (investing in hundreds of predicted targets) investors can profit from prediction modelling.
Test whether the variables in your model matter i.e., whether some variables can allow you to better predict.
Test whether models that are better able to predict targets, coincidentally earn higher abnormal returns.
Test whether the length of the estimation window (number of years of data used to develop model parameters) matters.
Test whether the model parameters are stable over time, i.e., whether once you develop parameters, you can use them recurrently to make successful predictions, like in Taffler Z scores.
Test whether the portfolio screening strategy suggested in Danbolt Siganos & Tunyi (2016) works in your case.
Explore other potential screening strategies -e.g., screening by recent performance, industry, age, industry concentration etc.
And many more, you can think of.

**/




