//                             Coursework Part 1

cls
clear
use Datafile1
set more off 
describe
browse



cls
clear
use Datafile2
describe
browse


cls
clear
use Datafile1
rename Year YEAR
save Datafile1edit, replace



clear
use Datafile2
drop if DSCD == ""
drop if YEAR ==.
save Datafile2edit, replace


clear
use Datafile1edit
merge 1:1 DSCD YEAR using Datafile2edit
drop if _merge==2
drop _merge

save Finaldata, replace




//                             Coursework Part 2

cls
clear
use Finaldata

*variable 1: dependent variable TARGET - dummy that takes 1 if a firm is a target

gen TARGET = TargetBidder == "Target"


*variable 2: Average excess return using the market index model

forvalues i = 1/12 {
	local j = `i'-1
	gen AR`i' = ((RiM`i'-RiM`j')/RiM`j') - ((RmM`i'-RmM`j')/RmM`j')
}


*generate average excess returns as buy an hold abnormal returns over the period

gen AER = ((1+AR1)*(1+AR2)*(1+AR3)* (1+AR4)*(1+AR5)*(1+AR6)*(1+AR7)*(1+AR8)*(1+AR9)*(1+AR10)*(1+AR11)*(1+AR12))-1


*Variable 3 - Profitability; ROCE, ROE

gen ROCE = EBIT/TCapital

gen ROE = NetIncomeCom/SEquity

gen ROA = NetIncomeCom/TAssets


*Variable 4 - Tobins Q; TobinsQ

gen MVEquity = (NOSH * UP/100)
gen BVDebt = TAssets - SEquity

gen TobinsQ = (BVDebt + MVEquity)/TAssets


*Variable 5 - Industry disturbance dummy; IDDUMY

* https://ideas.repec.org/c/boc/bocode/s458381.html
* http://kaichen.work/?p=294

*ssc install sicff

destring SICcode, generate(SICcode_n) force
sicff SICcode_n, ind(48)
ffind SICcode_n, newvar(ffi) type(48)



sort ff_48 YEAR

gen IDDUMMY= 0

egen Firmid = group(DSCD)
egen Yearid = group (YEAR)

sort Firmid Yearid
xtset Firmid Yearid

gen target_lastyear= l.TARGET

bysort ff_48 YEAR: egen IDSUM= total(target_lastyear)

replace IDDUMMY =1 if IDSUM>0

*Variable 6 - sales growth: SGRowth


sort Firmid YEAR
xtset Firmid YEAR

gen Lag_Revenues = L.Revenues
gen SGrowth = (Revenues-Lag_Revenues)/Lag_Revenues


*Variable 7 - Liquidity LIQ

gen LIQ = Cash/TAssets


* Variable 8 - Leverage; LEV

gen LEV = TDebt/(TCapital - LTDebt)


*Variable 9 - Growth Resource Mismatch dummy: GRDummy


* Alternative way for calculating GRDummy

bysort ff_48 YEAR: egen ISGW = median(SGrowth)

bysort ff_48 YEAR: egen ILIQ = median(LIQ)

bysort ff_48 YEAR: egen ILEV = median(LEV)

gen HSGW = 0 
replace HSGW = 1 if SGrowth > ISGW 
gen HLEV = 0
replace HLEV = 1 if LEV > ILEV
gen HLIQ = 0
replace HLIQ = 1 if LIQ > ILIQ
gen GRDUMMY = 0 
replace GRDUMMY = 1 if HSGW == 1 & HLEV == 1 & HLIQ == 0
replace GRDUMMY = 1 if HSGW == 0 & HLEV == 0 & HLIQ == 1

*Variable 10- firm size: SIZE

sort Firmid YEAR
xtset Firmid YEAR

gen SIZE = ln(TAssets)

*Variable 11 - free cash flow: FCF

gen FCF = (NCF_OP-Capex)/TAssets


*Variable 12 - Tangible property; PPE


gen PPE_Ratio = PPE/TAssets


*Variable 13 - Firm Age; AGE
gen ListAge = YEAR-BaseYear
gen Age= ln(1+ListAge)


*Variable 14 -Firm Age; AGE

bysort ff_48 YEAR: egen Industry_Revenue= total(Revenues)

gen MarketShareSquare= (Revenues/Industry_Revenue)^2

bysort ff_48 YEAR: egen HHI= total(MarketShareSquare) 


rename ZSCORE ZSC
rename Rumours RUM
rename Repurchases REP
rename LIBORBOEBR LIB
rename FTSEChange FTSEC
rename Msent MS
rename Volume VOL
rename BLOCK BLK



global Variables AER ROCE ROE ROA TobinsQ SGrowth SIZE FCF PPE_Ratio Age HHI

global Variables2  AER ROCE TobinsQ SGrowth SIZE PPE_Ratio Age HHI

global Variables3 AER ROE TobinsQ SGrowth SIZE FCF PPE_Ratio Age HHI

global Variables4 AER ROA SGrowth SIZE PPE_Ratio Age HHI



display $Variables

describe $Variables

summarize $Variables

bysort TARGET: summarize $Variables2


xtset Firmid Yearid

winsor2 AER ROCE ROE ROA TobinsQ SGrowth FCF , cuts(1 99) by(YEAR) replace



summarize $Variables



bysort TARGET: summarize $Variables


save Finaldata2, replace









//                             Coursework Part 3




cls
use Finaldata2, clear
set more off
xtset Firmid Yearid

*ssc install estout

estpost ttest $Variables, by (TARGET)
esttab ., wide

estpost ttest $Variables2, by (TARGET)
esttab ., wide

estpost ttest $Variables3, by (TARGET)
esttab ., wide

estpost ttest $Variables4, by (TARGET)
esttab ., wide


//                          Coursework Part 4

set more off

pwcorr $Variables , star(0.001) sig 

pwcorr $Variables2 , star(0.001) sig

pwcorr $Variables3 , star(0.001) sig

pwcorr $Variables4 , star(0.001) sig




logit TARGET $Variables , vce(cluster Firmid)
outreg2 using myreg1.doc, replace ctitle(Model1)pvalue dec(3)

logit TARGET $Variables2 , vce(cluster Firmid)
outreg2 using myreg1.doc, append ctitle(Model2)pvalue dec(3)



logit TARGET $Variables3 , vce(cluster Firmid)
outreg2 using myreg1.doc, append ctitle(Model3)pvalue dec(3)

logit TARGET $Variables4 , vce(cluster Firmid)
outreg2 using myreg1.doc, append ctitle(Model4)pvalue dec(3)



quietly {
	
logit TARGET $Variables  if YEAR <2005
predict P2005 if YEAR == 2005

logit TARGET $Variables  if YEAR <2006
predict P2006 if YEAR == 2006

logit TARGET $Variables  if YEAR <2007
predict P2007 if YEAR == 2007

logit TARGET $Variables  if YEAR <2008
predict P2008 if YEAR == 2008

logit TARGET $Variables  if YEAR <2009
predict P2009 if YEAR == 2009
}


egen Prob = rowtotal( P2005 P2006 P2007 P2008 P2009)



quietly{
xtile T2005 = P2005 if YEAR==2005, nq(10)
xtile T2006 = P2006 if YEAR==2006, nq(10)
xtile T2007 = P2007 if YEAR==2007, nq(10)
xtile T2008 = P2008 if YEAR==2008, nq(10)
xtile T2009 = P2009 if YEAR==2009, nq(10)
}

egen decile = rowtotal(T2005 T2006 T2007 T2008 T2009)




bysort YEAR: egen Rankings = rank (-Prob)

by YEAR: list DSCD Name Rankings if Rankings < 31

tabstat TARGET if decile == 10, by (YEAR) stat (sum count)

save investmentdata, replace




//                        Coursework Part 5


cls
use investmentdata, clear

keep DSCD YEAR Rankings July1 August September October November December January February March April May June July

drop if Rankings > 30


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

collapse (mean) $Returns, by(YEAR)
	

reshape long Return_, i(YEAR) j(Month_number)	
	
rename YEAR year
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


rename Month_number month

order year Month Return
save PortfolioReturns, replace

cls
use Datafile3, clear


clear
use PortfolioReturns



merge 1:1 year month using Datafile3

keep if _merge == 3
drop _merge


gen RiRf = Return - rf

reg RiRf rmrf, vce (robust) // CAPM with Huber White's Standard errors
outreg2 using Alpha.doc, replace ctitle(CAPM)pvalue dec(3)


reg RiRf rmrf smb hml , vce (robust)  //FF3F
outreg2 using Alpha.doc, append ctitle(FF3F)pvalue dec(3)

reg RiRf rmrf smb hml umd, vce (robust) // C4F 
outreg2 using Alpha.doc, append ctitle(C4F)pvalue dec(3)






