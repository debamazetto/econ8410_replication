cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to produce Table 1.
*It was created by Schwandt and Wachter (original: "05_Table_01") and modified by me.

*Note from the authors: this code generates the summary stats for the cohorts paper of Schwandt and von Wachter; the outcome variables come from the March files of IPUMS CPS; the main right handside variables are the state unemployment rates at graduation age or age 18.

*** Program produces table 1 ***

clear
set more off

*Directories
global dropbox "${rootdir}\Data" //rootdir comes from the config.do, I had to add that

global data "${dropbox}\merged_precollapse_1976_2016.dta"
global data_urate "${dropbox}\U rates\urateUSstate_1976_2016.dta"
global results "${dropbox}\Results\"

global outcomes1 "incwage hourly_earnings weeks hours_usual empl hhinc foodstmp stampval hi_priv hi_any hi_mcaid"
global outcomes2 "pubhous stampval nchild eitcred gotunemp anychild lwpar poor hi_any hi_priv married lnincwelfr lnincgov lnincssi lnincss lnincunemp lnincasist health_status fullpart"

*Sample selection
global minimumage "16" //Note from the authors: this is for the starting sample, the "minage" below is for the regression
global maximumage "40"

global minage "19"
global maxage "33"

global minyear "1979"
global maxyear "2016"

global mingradyear "1976"
global maxgradyear "2015"

global minexp "1"
global maxexp "15"

*** BASELINE SAMPLE RESTRICTIONS ***
global outcomes1 "incwage hourly_earnings weeks hours_usual empl hhinc foodstmp stampval hi_priv hi_any hi_mcaid"
{
	*Sample: All
	use "${data}", clear
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	collapse (mean) av_empl=empl av_lear=incwage av_lhear=hourly_earnings av_weeks=weeks av_ushours=hours_usual av_hhinc=hhinc av_fdstmp=foodstmp av_lstmpval=stampval av_hipr=hi_priv av_hian=hi_any av_himd=hi_mcaid ///
		(sd) sd_empl=empl sd_lear=incwage sd_lhear=hourly_earnings sd_weeks=weeks sd_ushours=hours_usual sd_hhinc=hhinc sd_fdstmp=foodstmp sd_lstmpval=stampval sd_hipr=hi_priv sd_hian=hi_any sd_himd=hi_mcaid ///
		(count)	Nu_empl=empl Nu_lear=incwage Nu_lhear=hourly_earnings Nu_weeks=weeks Nu_ushours=hours_usual Nu_hhinc=hhinc Nu_fdstmp=foodstmp Nu_lstmpval=stampval Nu_hipr=hi_priv Nu_hian=hi_any Nu_himd=hi_mcaid ///
		[iw = wtsupp]
	xpose, var clear
	rename v1 All
	list
	g num = _n
	sort num
	saveold "${results}sum_stats_all", replace
	
	*Sample: Male vs Female
	use "${data}", clear
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	collapse (mean) av_empl=empl av_lear=incwage av_lhear=hourly_earnings av_weeks=weeks av_ushours=hours_usual av_hhinc=hhinc av_fdstmp=foodstmp av_lstmpval=stampval av_hipr=hi_priv av_hian=hi_any av_himd=hi_mcaid ///
		(sd) sd_empl=empl sd_lear=incwage sd_lhear=hourly_earnings sd_weeks=weeks sd_ushours=hours_usual sd_hhinc=hhinc sd_fdstmp=foodstmp sd_lstmpval=stampval sd_hipr=hi_priv sd_hian=hi_any sd_himd=hi_mcaid ///
		(count)	Nu_empl=empl Nu_lear=incwage Nu_lhear=hourly_earnings Nu_weeks=weeks Nu_ushours=hours_usual Nu_hhinc=hhinc Nu_fdstmp=foodstmp Nu_lstmpval=stampval Nu_hipr=hi_priv Nu_hian=hi_any Nu_himd=hi_mcaid ///
		[iw = wtsupp], by (male)
	xpose, var clear
	rename v1 Female
	rename v2 Male
	g num = _n
	replace num = num - 1
	sort num
	saveold "${results}sum_stats_demog1", replace
	
	*Sample: White vs Non_white
	use "${data}", clear
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	collapse (mean) av_empl=empl av_lear=incwage av_lhear=hourly_earnings av_weeks=weeks av_ushours=hours_usual av_hhinc=hhinc av_fdstmp=foodstmp av_lstmpval=stampval av_hipr=hi_priv av_hian=hi_any av_himd=hi_mcaid ///
		(sd) sd_empl=empl sd_lear=incwage sd_lhear=hourly_earnings sd_weeks=weeks sd_ushours=hours_usual sd_hhinc=hhinc sd_fdstmp=foodstmp sd_lstmpval=stampval sd_hipr=hi_priv sd_hian=hi_any sd_himd=hi_mcaid ///
		(count)	Nu_empl=empl Nu_lear=incwage Nu_lhear=hourly_earnings Nu_weeks=weeks Nu_ushours=hours_usual Nu_hhinc=hhinc Nu_fdstmp=foodstmp Nu_lstmpval=stampval Nu_hipr=hi_priv Nu_hian=hi_any Nu_himd=hi_mcaid ///
		[iw = wtsupp], by (white)
	xpose, var clear
	rename v1 Non_white
	rename v2 White
	g num = _n	
	replace num = num - 1
	sort num
	saveold "${results}sum_stats_demog2", replace
	
	*Sample: Education groups
	use "${data}", clear
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	drop if ED4 == .
	
	collapse (mean) av_empl=empl av_lear=incwage av_lhear=hourly_earnings av_weeks=weeks av_ushours=hours_usual av_hhinc=hhinc av_fdstmp=foodstmp av_lstmpval=stampval av_hipr=hi_priv av_hian=hi_any av_himd=hi_mcaid ///
		(sd) sd_empl=empl sd_lear=incwage sd_lhear=hourly_earnings sd_weeks=weeks sd_ushours=hours_usual sd_hhinc=hhinc sd_fdstmp=foodstmp sd_lstmpval=stampval sd_hipr=hi_priv sd_hian=hi_any sd_himd=hi_mcaid ///
		(count)	Nu_empl=empl Nu_lear=incwage Nu_lhear=hourly_earnings Nu_weeks=weeks Nu_ushours=hours_usual Nu_hhinc=hhinc Nu_fdstmp=foodstmp Nu_lstmpval=stampval Nu_hipr=hi_priv Nu_hian=hi_any Nu_himd=hi_mcaid ///
		[iw = wtsupp], by (ED4)
	xpose, var clear
	label variable v1 "Less than 12 years"
	label variable v2 "12 years"
	label variable v3 "13 to 15 years"
	label variable v4 "More than 15 years"
	rename v1 less_than_12_years
	rename v2 equal_to_12_years
	rename v3 between_13_and_15_years
	rename v4 more_than_15_years
	g num = _n
	replace num = num - 1
	sort num
	saveold "${results}sum_stats_educ", replace
	
	*Merging
	use "${results}sum_stats_educ", clear
	merge 1:1 num using "${results}sum_stats_demog1"
	drop _merge
	merge 1:1 num using "${results}sum_stats_demog2"
	drop _merge
	merge 1:1 num using "${results}sum_stats_all"
	drop _merge
	list
	
	drop if num == 0
	g variable = substr(_varname,4,10)
	order variable All Male Female White Non_white less_than_12_years equal_to_12_years between_13_and_15_years more_than_15_years
	
	gen ord = 0
	replace ord = 1 if inrange(num,1,11)
	replace ord = 2 if inrange(num,12,22)
	replace ord = 3 if inrange(num,23,33)
	
	gen ord2 = 0
	replace ord2 = 1 if variable == "lear"
	replace ord2 = 2 if variable == "lhear"
	replace ord2 = 3 if variable == "hhinc"
	replace ord2 = 4 if variable == "weeks"
	replace ord2 = 5 if variable == "ushours"
	replace ord2 = 6 if variable == "empl"
	replace ord2 = 7 if variable == "fdstmp"
	replace ord2 = 8 if variable == "lstmpval"
	replace ord2 = 9 if variable == "hian"
	replace ord2 = 10 if variable == "hipr"
	replace ord2 = 11 if variable == "himd"
	
	sort ord2 ord
	
	saveold "${results}sum_stats_baseline", replace
}

*Exporting Table 1 - I had to add this part
use "${results}sum_stats_baseline", clear
keep if ord == 1
drop _varname num ord ord2
outsheet using "${results}sum_stats_baseline.txt", replace

cap log close //I had to add that
