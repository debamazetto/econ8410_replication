cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to produce Figure 1.
*It was created by Schwandt and Wachter (original: "02_Figure_01") and modified by me.

*** Program produces Figure 1 ***

global dropbox "${rootdir}\Data" //rootdir comes from the config.do, I had to add that

global data "${dropbox}"
global mortresults "${dropbox}Results\"
global temp "${dropbox}Results\"
global resultspaper "${dropbox}\Results\"

global datacensus "${dropbox}\Census\usa_00001.dta"

global datasave "${dropbox}"
global data_urate  "${dropbox}\U rates\urateUSstate_1976_2016.dta"

*** Collapse and FEs ***
global collapse_exp "state grady exp ED4"
global FE_exp "i.state i.gradyear i.exp i.year i.ED"

global collapse_age "state yob age"
global FE_age "i.state i.yob i.age i.year"

*** Sample selection ***
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

*** Load micro data ***
use birthyr year incw educ state perwt bpl using "${datacensus}", clear
rename state state
keep if bpl <= 56
rename birthyr yob
rename bpl sob

gen age = year - yob

keep if inrange(age,16,39) & inrange(year,${minyear},${maxyear})

gen lnincwage = ln(incwag) if incwag < 999999
gen eduyears = 0 if educ == 0
replace eduyears = 4 if educ == 1
replace eduyears = 7 if educ == 2
replace eduyears = 9 if educ == 3
replace eduyears = 10 if educ == 4
replace eduyears = 11 if educ == 5
replace eduyears = 12 if educ == 6
replace eduyears = 13 if educ == 7
replace eduyears = 14 if educ == 8
replace eduyears = 15 if educ == 9
replace eduyears = 16 if educ == 10
replace eduyears = 18 if educ == 11
drop educ*

gen gradyear = round(yob + 6 + eduyears)
gen exp = year - gradyear

keep if inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear})

gen cellsize = 1

*** 3B. Collapse ***
collapse $outcomes (sum) cellsize [iw = perwt], by(state grady exp sob yob)

*** 3A. Merge double weighted MigrTime u-rate ***
merge m:1 sob yob using "${datasave}\urate_migration_time_adjusted", keep(3) nogen //it's necessary to run file 04 first to obtain this database

*** 3C. Merge Mincer u-rate ***
merge m:1 gradyear state using "${data_urate}", keep(3) nogen
rename urateUSstate ustate

gen year = grady + exp
gen age = year - yob
gen gystate = grady*100 + state
gen _exp = 1 in 1

label var uM "Double-Weighted unemployment rate"
label var ustate "Mincerian unemployment rate"
label define sob 6 "California" 12 "Florida" 36 "New York" 48 "Texas"
label values sob sob
label values state sob

gen temp = ustate*cellsize
bysort yob sob: egen sumN = sum(cellsize)
bysort yob sob: egen AV_ustate = sum(temp)
gen av_ustate = AV/sumN

gen temp2 = uMig*cellsize
bysort grady state: egen sumN2 = sum(cellsize)
bysort grady state: egen AV2_u = sum(temp2)
gen av2_u = AV2/sumN2

*Figure 1
sort yob 
twoway ///
	(scatter ustate yob [aw = cellsize], mcolor(blue) msize(.3) msymbol(Oh)) ///
	(line uMigrTime yob, lcolor(red) lwidth(1.5)) ///
	(line av_ustate yob, lcolor(black) lwidth(.5)) ///
	if inlist(sob,6,36,48,12) & inrange(ustate,3,13), ///
	by(sob, graphregion(color(white)) note("Graphs by state of birth")) ylab(3(5)13) xlab(1960(10)1990) xtitle("Year of birth") ///
	legend(symxsize(6) order(1 "Mincerian unemployment rate" 2 "Double-Weighted unemployment rate" 3 "Average Mincerian rate"))
graph export "${resultspaper}figure1.png", replace //I added this line to save graphs as image

cap log close //I had to add that
