cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to produce Figures 3 and 4.
*It was created by Schwandt and Wachter (original: "04_Figures_03_04") and modified by me.

*** Program produces Figures 3 and 4 ***

*** GLOBALS ***
*Directories
global dropbox "${rootdir}\Data" //rootdir comes from the config.do, I had to add that

global datacensus "${dropbox}\Census\usa_00001.dta"
global datacps "${dropbox}\merged_precollapse_1976_2016.dta"

global datasave "${dropbox}"
global data_urate  "${dropbox}\U rates\urateUSstate_1976_2016.dta"
global results  "${dropbox}\Results\"
global resultspaper "${dropbox}\Results\"

*Collapse and FEs
global collapse_exp "state grady exp ED4"
global FE_exp "i.state i.gradyear i.exp i.year i.ED"

global collapse_age "state yob age"
global FE_age "i.state i.yob i.age i.year"

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

*Graph options
global graph1 "connect(l) color(red) lwidth(medthick) msymbol(T) msize(large)"
global graph2 "connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(medium)"
global graph3 "connect(l) color(green) msymbol(Dh) msize(large)"
global graphoptions "graphregion(color(white)) xlabel(1(2)15) xtitle("Years since Graduation", size(large)) yline(0, lcolor(black)) xlabel(,labsize(large)) ylabel(,labsize(large))"
global graphoptionsage "graphregion(color(white)) xlabel(19(2)33) xtitle("Age", size(large)) yline(0, lcolor(black)) xlabel(,labsize(large)) ylabel(,labsize(large))"

*** MIGRATION MATRIX ***
{
	*Note from the authors: where were people at age 18? Get age 18 migration rates Census 1970-2000, ACS 2011-2014.
	use if bpl <= 56 & inrange(birthyr,1952,2000) using "${datacensus}", clear
	
	gen age = year - birthy
	
	keep if inlist(age,16,18,20,22)
	
	levelsof state
	foreach x in `r(levels)' {
		gen s`x'=(state==`x')
	}
	
	drop state sex
	keep s* bpl perwt year age
	
	replace perwt = perwt*10 if year <= 1990  //Note from the authors: because these represent the average effects of 10 years each
	
	collapse s* [iw = perwt], by(bpl age)
	rename bpl sob
	
	save "${datasave}\Age18_migration_matrix.dta", replace
}

*** TIMING MATRIX ***
{
	*Note from the authors: when did people graduate? Which shares at 10, 12, 14, 16 yrs?
	
	use "${datacensus}", clear
	drop bpld statefip sex
	
	keep if bpl <= 56
	
	rename birthyr yob
	gen age = year - yob
	
	keep if inrange(age,${minage},${maxage}) & inrange(year,${minyear},${maxyear})
	
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
	
	gen gradyear = year - age + 6 + eduyears
	replace gradyear = . if year <= gradyear
	
	gen exp = year - gradyear
	
	keep if exp > 1 & exp < .
	
	gen s_ed10 = eduy < 12
	gen s_ed12 = eduy == 12
	gen s_ed14 = inrange(eduy,13,15)
	gen s_ed16 = eduy > 15 & eduy < .
	
	rename bpl sob
	replace perwt = perwt*10 if year <= 1990  //Note from the authors: because these represent the average effects of 10 years each
	
	collapse s_ed* [iw = perwt], by (yob sob)	
	
	egen check = rowtotal(s_ed*)
	tab check
	
	*Note from the authors: predict education shares
	foreach var of varlist s_ed* {
		qui xi: reg  `var' i.sob i.yob
		predict _`var'
	}
	drop _I* s_ed*
	
	keep yob sob _s_ed*
	save "${datasave}\Timing_matrix_wide.dta", replace
	
	*Note from the authors: make long to wide
	reshape long _s_ed, i(yob sob) j(eduyears)
	rename _s_ed _edushares
	
	gen gradyear = yob + eduyears + 6
	drop eduyears
	
	gen age = grad - yob
	
	save "${datasave}\Timing_matrix.dta", replace
}	

*** Create non-existent database ***
use "${datasave}\U rates\urateUSstate_1976_2016.dta", clear

ren urateUSstate u

reshape wide u, i(gradyear) j(state)

ren gradyear year
sort year

save "${datasave}\urate_1976_2016_wide.dta", replace 

*** MERGE TIMING AND MIGRATION SHARES ***
{
	*Note from the authors: merge migration and timing shares. Note that migration shares are wide, timing shares are long
	use "${datasave}\Timing_matrix.dta", clear
	merge m:1 sob age using "${datasave}\Age18_migration_matrix.dta", nogen
	
	*Note from the authors: generate figure with graduation shares
	preserve
	sort sob yob grad
	keep if sob == 6 & yob == 1980
	foreach var of varlist s1-s56 {
		qui replace `var' = `var'*_edushares
	}
	gen gradage = gradyear - yob
	drop _edushares gradyear yob sob
	
	reshape long s, i(gradage) j(state)
	
	scatter gradage state [aw = s], msize(1) msymbol(Oh) graphregion(color(white)) mcolor(blue) ///
		xlabel(1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" ///
			45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY", labsize(1.5)) ///
		ytitle("Age at labor market entry") xtitle(State of residence)
	restore
	
	*Note from the authors: merge u-rate in wide-form
	keep if yob >= 1960 //Note from the authors: for earlier cohorts there are no eduy=10 u-rate
	rename gradyear year
	merge m:1 year using "${datasave}\urate_1976_2016_wide.dta", nogen keep(3) //this database does not exist, I had to create it
	rename year gradyear
	
	*Note from the authors: first sum up the wide form over states
	gen u_migration = 0
	
	levelsof sob
	foreach z in `r(levels)' {
		qui replace u_migration = u_migration + s`z'*u`z'
		drop  s`z' u`z'
	}
	
	*Note from the authors: now sum up long form over gradyears!
	gen uMigrTime = u_migration*_edushares
	collapse (sum) uMigrTime, by(sob yob)
	
	label var uMigrTime "U-rate adjusted for migration and timing, by SoB and YoB"
	
	save "${datasave}\urate_migration_time_adjusted.dta", replace
}

*** CENSUS BASELINE (EXP): EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
{
	*1. Additional globals
	global outcomes "lnincwage"
	
	*2. Load data, define sample and variables
	use birthyr year incw educ state perwt using "${datacensus}", clear
	rename state state
	rename birthyr yob
	
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
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	replace perwt = perwt*10 if year <= 1990 //Note from the authors: because these represent the average effects of 10 years each
	gen cellsize = 1
	
	*3. Collapse
	collapse $outcomes (sum) cellsize [iw = perwt], by($collapse_exp)
	
	*4. Merge u-rate
	merge m:1 gradyear state using "${data_urate}", keep(3) nogen
	rename urateUSstate ustate
	
	*5. Interactions and controls
	forvalues e = 1/15 {
		gen e`e' = (exp == `e')
		gen exp`e'usta = e`e'*usta
		drop e`e'
	}
	gen year = grady + exp
	gen gystate = grady*100 + state
	gen _exp = 1 in 1
	
	*6. Regress and get coeffs
	set more off
	foreach var of global outcomes {
		reg `var' exp${minexp}usta - exp${maxexp}usta $FE_exp [aw = cellsize], cluster(gystate)
		qui gen _`var' = _b[exp1usta] in 1
		qui gen se_`var' = _se[exp1usta] in 1
		
		qui forvalues y = 2/$maxexp {
			replace _exp = `y' in `y'
			replace _`var' = _b[exp`y'usta] in `y'
			replace se_`var' = _se[exp`y'usta] in `y'
		}
	}
	rename _lnincwage _CensusInc_SoR
	
	keep if _exp != .
	keep _* se_*
	
	save "${results}\Census_exp_SOR", replace
}

*** CENSUS BASELINE (EXP): ... AT STATE OF BIRTH ***
{
	*1. Additional globals
	global outcomes "lnincwage"
	
	*2. Load data, define sample and variables
	use birthyr year incw educ bpl perwt using "${datacensus}", clear
	keep if bpl <= 56
	rename bpl state
	rename birthyr yob
	
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
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	replace perwt = perwt*10 if year <= 1990 //Note from the authors: because these represent the average effects of 10 years each
	gen cellsize = 1
	
	*3. Collapse
	collapse $outcomes (sum) cellsize [iw = perwt], by($collapse_exp)
	
	*4. Merge u-rate
	merge m:1 gradyear state using "${data_urate}", keep(3) nogen
	rename urateUSstate ustate
	
	*5. Interactions and controls
	forvalues e = 1/15 {
		gen e`e' = (exp == `e')
		gen exp`e'usta = e`e'*usta
		drop e`e'
	}
	
	gen year = grady + exp
	gen gystate = grady*100 + state
	gen _exp = 1 in 1
	
	*6. Regress and get coeffs
	foreach var of global outcomes 	{
		reg `var' exp${minexp}usta - exp${maxexp}usta $FE_exp [aw = cellsize], cluster(gystate)
		qui gen _`var' = _b[exp1usta] in 1
		qui gen se_`var' = _se[exp1usta] in 1
		
		qui forvalues y = 2/$maxexp {
			replace _exp = `y' in `y'
			replace _`var' = _b[exp`y'usta] in `y'
			replace se_`var' = _se[exp`y'usta] in `y'
		}
	}
	
	rename _lnincwage _CensusInc_SoB
	
	keep if _exp != .
	keep _* se_*
	
	save "${results}\Census_exp_SoB", replace
}

*** CENSUS (AGE): ADJUSTING FOR MIGRATION AND TIMING ("DOUBLE WEIGHTED") ***
{
	*** EFFECTS OF PREDICTED UNEMPLOYMENT RATE ***
	*1. Additional globals
	global outcomes "lnincwage"
	
	*2. Load data, define sample and variables
	use birthyr year incw educ bpl perwt using "${datacensus}", clear
	keep if bpl <= 56
	rename bpl state
	rename birthyr yob
	
	gen age = year - yob
	
	keep if inrange(age,16,39) & inrange(age,${minage},${maxage}) & inrange(year,${minyear},${maxyear})
	
	gen lnincwage = ln(incwag) if incwag < 999999
	gen cellsize = 1
	replace perwt = perwt*10 if year <= 1990 //Note from the authors: because these represent the average effects of 10 years each
	
	*3. Collapse
	collapse $outcomes (sum) cellsize [iw = perwt], by($collapse_age)
	
	*4. Merge PREDICTED MigrTime u-rate
	rename state sob
	merge m:1 sob yob using "${datasave}\urate_migration_time_adjusted", keep(3) nogen
	rename sob state
	
	*5. Interactions and controls
	forvalues e = $minage/$maxage {
		gen e`e' = (age == `e')
		gen age`e'uMigrTime = e`e'*uMigrTime
		drop e`e'
	}
	
	gen year = yob + age
	gen gystate = yob*100 + state
	gen _age = ${minage} in ${minage}
	
	*6. Regress and get coeffs
	foreach var of global outcomes {
		reg `var' age${minage}uMigrTime - age${maxage}uMigrTime $FE_age [aw = cellsize], cluster(gystate)
		qui gen _`var' = _b[age19uMigrTime] in ${minage}
		qui gen se_`var' = _se[age19uMigrTime] in ${minage}
		
		local z = ${minage} + 1
		qui forvalues y = `z'/$maxage {
			replace _age = `y' in `y'
			replace _`var' = _b[age`y'uMigrTime] in `y'
			replace se_`var' = _se[age`y'uMigrTime] in `y'
		}
	}
	
	rename _lnincwage _CensusInc_Adj
	
	keep if _age != .
	keep _* se_*
	
	save "${results}\Census_age_TimeMigr_Adj", replace
}

cap ssc install ivreg2 //I had to install this command
cap ssc install ranktest //I had to install this command

*** CENSUS , using DOUBLE WEIGHTED as INSTRUMENT for baseline u-rate ***
{
	*1. Additional globals
	global outcomes "lnincwage"
	
	*2. Load data, define sample and variables
	use birthyr year incw educ state perwt bpl  using "${datacensus}", clear
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
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	replace perwt = perwt*10 if year <= 1990 //Note from the authors: because these represent the average effects of 10 years each
	gen cellsize = 1
	
	*3B. Collapse
	collapse $outcomes (sum) cellsize [iw = perwt], by(state grady exp ED4 sob yob)
	
	*3A. Merge DOUBLE WEIGHTED MigrTime u-rate
	merge m:1 sob yob using "${datasave}\urate_migration_time_adjusted", keep(3) nogen
	
	*3C. Merge Mincer u-rate
	merge m:1 gradyear state using "${data_urate}", keep(3) nogen
	rename urateUSstate ustate
	
	*5. Interactions and controls
	gen ExpUstate = exp*ustate
	gen ExpUiv = exp*uMigrTime
	
	forvalues e = 1/15 {
		gen e`e' = (exp == `e')
		gen exp`e'usta = e`e'*usta
	}
	
	forvalues e = 1/15 {
		gen IVexp`e'uMigrTime = e`e'*uMigrTime
		drop e`e'
	}
	
	gen year = grady + exp
	gen age = year - yob
	gen gystate = grady*100 + state
	gen _exp = 1 in 1
	
	*6. Regress and get coeffs
	foreach var of global outcomes {
		xi: ivreg2 `var' (exp${minexp}usta - exp${maxexp}usta = IVexp${minexp}uMigrTime - IVexp${maxexp}uMigrTime) i.state i.gradyear i.exp i.year i.ED i.sob i.yob i.age [aw = cellsize], r cluster(gystate)
		qui gen _`var' = _b[exp1usta] in 1
		qui gen se_`var' = _se[exp1usta] in 1
		
		qui forvalues y = 2/$maxexp {
			replace _exp = `y' in `y'
			replace _`var' = _b[exp`y'usta] in `y'
			replace se_`var' = _se[exp`y'usta] in `y'
		}
	}
	
	rename _lnincwage _CensusInc_IV
	
	keep if _exp != .
	keep _* se_*
	
	save "${results}\Census_IV", replace
}

*** CENSUS vs CPS: COMPARISON FIGURE ***
use _exp _lnincwage using "${results}\exp_baseline", clear //it's necessary to run file 03 first to obtain this database
merge 1:1 _exp using "${results}\Census_exp_Sor", nogen
merge 1:1 _exp using "${results}\Census_exp_SoB", nogen
merge 1:1 _exp using "${results}\Census_IV", nogen

gen _age = _exp + 18
merge 1:1 _age using "${results}\Census_age_TimeMigr_Adj", nogen

*Figure 3
twoway (scatter _lnincwage _exp, $graph1) ///
	(scatter _CensusInc_SoR _exp, $graph2) ///
	(scatter _CensusInc_Adj _exp, $graph3) ///
	(line _CensusInc_SoB _exp, lcolor(black) ), ///
	legend(size(3.5) symysize(1) ///
	order(1 "CPS, Mincerian (baseline)" 2 "Census, Mincerian" 4 "Census, using state of birth" 3 "Census, Double-Weighted [by age]") ///
	symxsize(4) col(2)) ytitle("Effect on log earnings", size(large)) ///
	saving("${results}robust_Census_CPS_age_Adj", replace) $graphoptionsage ylabel(-.04(.02).02) xtitle("Years since Graduation [Age]", height(6)) xlabel(1 "1 [19]" 5 "5 [23]" 9 "9 [27]" 13 "13 [31]")
graph export "${resultspaper}bridge_Census_CPS_age_Adj.eps", replace

*With IV specification
* Figure 4
twoway (scatter _lnincwage _exp, $graph1) ///
	(scatter _CensusInc_SoR _exp, $graph2) ///
	(scatter _CensusInc_Adj _exp, $graph3) ///
	(line _CensusInc_IV _exp, lcolor(black) lwidth(.8)), ///
	legend(order(1 "CPS, Mincerian (baseline)" 2 "Census, Mincerian" 3 "Census, Double-Weighted" 4 " Double-Weighted as IV for baseline" ) symxsize(4) col(2)) ytitle("Effect on log earnings", size(large)) ///
	$graphoptionsage ylabel(-.06(.02).02) xtitle("Years since Graduation [Age]", height(6)) xlabel(1 "1 [19]" 5 "5 [23]" 9 "9 [27]" 13 "13 [31]")
graph export "${resultspaper}bridge_Census_CPS_age_Adj_IV.eps", replace

cap log close //I had to add that
