cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to load data for states' unemployment rates. This data can be downloaded, as shown by the authors, at http://download.bls.gov/pub/time.series/la/.
*It was created by Schwandt and Wachter (original: "01_Cleaning_CPS") and modified by me.

*** Directories ***
global dropbox "${rootdir}\Data" //rootdir comes from the config.do, I had to add that
global pathdata "${dropbox}"
global pathresults "${dropbox}\Results\"

use "${pathdata}\CPS\cps_00005.dta", clear //I used the name of my raw data downloaded from the CPS website
set more off

*** Code years of education ***
*Note from the authors: we ommit educ=70 and educ=120; the reason is that there are 0 obs with these values. Moreover, we assume that everybody with a barcelor degree -educ=111- needed 16 years of education (i.e. graduated in 4 years).
gen eduyears = .
replace eduyears = . if educ == 1
replace eduyears = 0 if educ == 2
replace eduyears = 3 if educ == 10
replace eduyears = 1 if educ == 11
replace eduyears = 2 if educ == 12
replace eduyears = 3 if educ == 13
replace eduyears = 4 if educ == 14
replace eduyears = 5.5 if educ == 20
replace eduyears = 5 if educ == 21
replace eduyears = 6 if educ == 22
replace eduyears = 7.5 if educ == 30
replace eduyears = 7 if educ == 31
replace eduyears = 8 if educ == 32
replace eduyears = 9 if educ == 40
replace eduyears = 10 if educ == 50
replace eduyears = 11 if educ == 60
replace eduyears = 12 if educ == 71
replace eduyears = 12 if educ == 72
replace eduyears = 12 if educ == 73
replace eduyears = 13 if educ == 80
replace eduyears = 14 if educ == 81
replace eduyears = 14 if educ == 90
replace eduyears = 14 if educ == 91
replace eduyears = 14 if educ == 92
replace eduyears = 15 if educ == 100
replace eduyears = 16 if educ == 110
replace eduyears = 16 if educ == 111
replace eduyears = 17 if educ == 121
replace eduyears = 18 if educ == 122
replace eduyears = 18 if educ == 123
replace eduyears = 18 if educ == 124
replace eduyears = 20 if educ == 125

*** Create college dummy ***
gen college = (educ >= 80)
replace college = . if (educ == 0 | educ == 01 | educ == 999)

gen colldeg = (educ >= 111)
replace colldeg = . if (educ == 0 | educ == 01 | educ == 999)

gen highschool = (eduyears == 12)
replace highschool = . if (educ == 0 | educ == 01 | educ == 999)

gen morehs = (eduyears > 12)
replace morehs = . if (educ == 0 | educ == 01 | educ == 999)

*Note from the authors: if the vars are equal to 999999 or 999998 they are either not in universe or missing.
replace inctot = . if inctot >= 999998
replace incwage = . if incwage >= 999998
replace hhincome = . if hhincome >= 999998
replace hourwage = . if hourwage >= 99.98 //this variable was not listed in the original data source document
replace earnweek = . if earnweek >= 9999.98 //this variable was not listed in the original data source document
replace incss = . if incss >= 99998 //this variable was not listed in the original data source document
replace incssi = . if incssi >= 99998 //this variable was not listed in the original data source document
replace incwelfr = . if incwelfr >= 99998 //this variable was not listed in the original data source document
replace incgov = . if incgov >= 99998 //this variable was not listed in the original data source document
replace incdisab = . if incdisab >= 999998 //this variable was not listed in the original data source document
replace incunemp = . if incunemp >= 99998 //this variable was not listed in the original data source document
replace incasist = . if incasist >= 99998 //this variable was not listed in the original data source document
replace stampval = . if stampval == 0 //this variable was not listed in the original data source document

*** Dummies for positive wage and annual income ***
gen pos_wage = (hourwage > 0) if hourwage ~= .
gen pos_earn = (earnweek > 0) if earnweek ~= .
gen pos_inc = (incwage > 0) if incwage ~= .

*** Inflation adjustment using Consumer Price Index adjustment factors ***
foreach var of varlist hhincome inctot incwage earnweek hourwage ///
         incss incssi incwelfr incgov incdisab incunemp incasist stampval{
	replace `var' = `var'*5.572 if year == 1962
	replace `var' = `var'*5.517 if year == 1963
	replace `var' = `var'*5.444 if year == 1964
	replace `var' = `var'*5.374 if year == 1965
	replace `var' = `var'*5.289 if year == 1966
	replace `var' = `var'*5.142 if year == 1967
	replace `var' = `var'*4.988 if year == 1968
	replace `var' = `var'*4.787 if year == 1969
	replace `var' = `var'*4.54 if year == 1970
	replace `var' = `var'*4.294 if year == 1971
	replace `var' = `var'*4.114 if year == 1972
	replace `var' = `var'*3.986 if year == 1973
	replace `var' = `var'*3.752 if year == 1974
	replace `var' = `var'*3.379 if year == 1975
	replace `var' = `var'*3.097 if year == 1976
	replace `var' = `var'*2.928 if year == 1977
	replace `var' = `var'*2.749 if year == 1978
	replace `var' = `var'*2.555 if year == 1979
	replace `var' = `var'*2.295 if year == 1980
	replace `var' = `var'*2.022 if year == 1981
	replace `var' = `var'*1.833 if year == 1982
	replace `var' = `var'*1.726 if year == 1983
	replace `var' = `var'*1.673 if year == 1984
	replace `var' = `var'*1.603 if year == 1985
	replace `var' = `var'*1.548 if year == 1986
	replace `var' = `var'*1.52 if year == 1987
	replace `var' = `var'*1.467 if year == 1988
	replace `var' = `var'*1.408 if year == 1989
	replace `var' = `var'*1.344 if year == 1990
	replace `var' = `var'*1.275 if year == 1991
	replace `var' = `var'*1.223 if year == 1992
	replace `var' = `var'*1.187 if year == 1993
	replace `var' = `var'*1.153 if year == 1994
	replace `var' = `var'*1.124 if year == 1995
	replace `var' = `var'*1.093 if year == 1996
	replace `var' = `var'*1.062 if year == 1997
	replace `var' = `var'*1.038 if year == 1998
	replace `var' = `var'*1.022 if year == 1999
	replace `var' = `var'*1 if year == 2000
	replace `var' = `var'*0.967 if year == 2001
	replace `var' = `var'*0.941 if year == 2002
	replace `var' = `var'*0.926 if year == 2003
	replace `var' = `var'*0.905 if year == 2004
	replace `var' = `var'*0.882 if year == 2005
	replace `var' = `var'*0.853 if year == 2006
	replace `var' = `var'*0.826 if year == 2007
	replace `var' = `var'*0.804 if year == 2008
	replace `var' = `var'*0.774 if year == 2009
	replace `var' = `var'*0.777 if year == 2010
	replace `var' = `var'*0.764 if year == 2011
	replace `var' = `var'*0.741 if year == 2012
	replace `var' = `var'*0.726 if year == 2013
	replace `var' = `var'*0.715 if year == 2014
	replace `var' = `var'*0.704 if year == 2015
	replace `var' = `var'*0.703 if year == 2016
	gen ln`var' = ln(`var')
}

*** Dependent Variables ***
gen unempl = (empstat >= 20 & empstat < 30) if empstat != 0
gen empl = (empstat >= 10 & empstat < 20) if empstat != 0
gen NILF = (empstat >= 30) if empstat != 0
gen army = (empst == 13) if empstat != 0

*** Create state migration dummies ***
gen move1 = (migrate1 == 5) if migrate1 ~= . & migrate1 > 0
gen move5 = (migrate5 == 51 | migrate5 == 52) if migrate5 ~= . & migrate5 > 0 //migrate5 variable was not listed in the original data source document

*** Income of head and spouse ***
gen lnhh_own = lnhhinc if relate == 101 | relate == 201

gen white = (race == 100) if race < 999
gen black = (race == 200) if race < 999

drop race

gen married = (marst == 1 | marst == 2) if marst < 9
gen single = (marst == 6) if marst < 9
replace ncouples = 2 if ncouples > 2 & ncouples < .

gen anychild = (nchil != 0)
gen lwpar = (relate == 301)
gen sin_par = (nchild > 0 & ncouples == 0)

gen pubhh = (pubhous == 2) if pubhous > 0 & pubhous < .
gen pubhh_all = (pubhh == 1) if pubhous < .

gen poor = (poverty == 10) if poverty > 0 & poverty < .
drop poverty

gen migwicounty = (migrate1 == 3) if migrate1 < .
gen migcounty = (migrate1 == 4) if  migrate1 < .
gen migstate = (migrate1 == 5) if migrate1 < .

replace disabwrk = disabwrk - 1
replace disabwrk = . if disabwrk < 0

gen hi_priv = (coverpi == 2) if coverpi < 3
gen hi_privown = (phiown == 2) if phiown < 3 & phiown > 0
gen hi_empl = (inclugh == 2) if inclugh < 3 & inclugh > 0
gen hi_e_work = (inclugh == 2) if inclugh < 3 & inclugh > 0 & empst < 20
gen hi_mcaid = (himcaid == 2) if himcaid < 3
gen hi_any = (hi_priv == 1 | hi_mcaid == 1) if hi_priv != .

replace foodstmp = (foodstmp == 2) if foodstmp ~= . //foodstmp variable was not listed in the original data source document

replace fullpart = . if fullpart == 0 //fullpart variable was not listed in the original data source document
replace fullpart = fullpart - 1

replace kidcaid = kidcaid - 1 
replace kidcaid = . if kidcaid < 0

replace hcovany = (hcovany - 3)*-1 if year == 2000

foreach var of varlist hcovany hcovpriv {
	replace `var' = `var' - 1
}

gen srhealth = 6 - health

gen male = (sex == 1)

gen gradyear = year - age + 6 + eduyears
replace gradyear = . if year <= gradyear

rename statefip state

gen cellsize = 1

*** Create employment outcome variables ***
rename wkswork1 weeks  //this variable was not listed in the original data source document
rename uhrsworkly hours_usual //this variable was not listed in the original data source document
rename ahrsworkt hours //this variable was not listed in the original data source document
replace hours_usual = . if hours_usual > 99
replace hours = . if hours > 99
gen lnweeks = ln(weeks)
gen lnhours_usual = ln(hours_usual)
gen lnhours = ln(hours)

*** Create hourly earnings ***
gen annual_hours = hours_usual*weeks
gen hourly_earnings = incwage/annual_hours
gen lnhourly_ear = log(hourly_earnings)

compress
saveold  "${pathdata}\merged_precollapse_1976_2016.dta", replace

cap log close //I had to add that
