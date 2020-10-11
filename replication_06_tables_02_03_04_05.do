cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to produce Table 1.
*It was created by Schwandt and Wachter (original: "06_Tables_02_03_04_05") and modified by me.

*Note from the authors: this code generates the tables for the cohorts paper of Schwandt and von Wachter; the outcome variables come from the March files of IPUMS CPS; the main right handside variables are the state unemployment rates at graduation age or age 18.

*** Program produces tables 2, 3, 4, 5 ***

clear
set more off

*** PRELIMINARIES (Always run this part of the code; these globals are used below) ***
*Directories
global dropbox "${rootdir}\Data" //rootdir comes from the config.do, I had to add that

global data "${dropbox}\merged_precollapse_1976_2016.dta"
global data_urate "${dropbox}\U rates\urateUSstate_1976_2016.dta"
global results "${dropbox}\Results\"

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

*Outcome variables
global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid hi_any hi_priv foodstmp lnstampval poor nonempl zeroweeks"

*Graph options
global graph1 "connect(l) color(red) lwidth(medthick) msymbol(T) msize(large)"
global graph2 "connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(medium)"
global graphoptions "graphregion(color(white)) xlabel(1(2)15) xtitle("Years since Graduation", size(large))  yline(0, lcolor(black))  xlabel(,labsize(large)) ylabel(,labsize(large))"
global graphoptionsage "graphregion(color(white)) xlabel(19(2)33) xtitle("Age", size(large))  yline(0, lcolor(black))  xlabel(,labsize(large)) ylabel(,labsize(large))"

*Comprehensive list of outcomes: white black hourly_earnings lnhourly_ear male married eduy hi_mcaid hcovpriv lnincwage lnhh_own pos_wage pos_earn pos_inc unempl NILF empl lnweeks lnhours lnhours_usual lnhourwage lnearnweek migstate move1 move5 lnincss lnincssi lnincwelfr lnincgov lnincdisab lnincunemp lnincasist lnstampval foodstmp college colldeg highschool morehs hi_any

*** BASELINE: EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
{
	*1. Additional globals
	global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid hi_any hi_priv foodstmp lnstampval fullpart poor nonempl zeroweeks"
	
	*2. Load data, define sample and variables
	use "${data}", clear
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	gen nonempl = 1 - empl
	gen zeroweeks = (weeks == 0)
	
	*3. Collapse
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off

	collapse $outcomes (sum) cellsize [iw = wtsupp], by($collapse_exp)
	
	*4. Merge u-rate
	merge m:1 gradyear state using "${data_urate}", keep(3) nogen
	rename urateUSstate ustate
	
	*5. Interactions and controls
	*Generate the experience groups
	gen exp_group = 0
	replace exp_group = 1 if exp >= 0 & exp <= 3
	replace exp_group = 2 if exp >= 4 & exp <= 5
	replace exp_group = 3 if exp >= 6 & exp <= 7
	replace exp_group = 4 if exp >= 8 & exp <= 10
	replace exp_group = 5 if exp >= 11 & exp <= 15
	
	forvalues i = 1/5 {
		gen gp`i' = (exp_group == `i')
		gen exp_group`i'usta = gp`i'*ustate
	}
	
	gen year = grady + exp
	gen gystate = grady*100 + state
	gen _exp_group = 1 in 1
	
	*6. Regress and get coeffs
	foreach var of global outcomes {
		reg `var' exp_group1usta - exp_group5usta $FE_exp [aw = cellsize], cluster(gystate)
		qui gen _`var' = _b[exp_group1usta] in 1
		qui gen se_`var' = _se[exp_group1usta] in 1
		
		qui forvalues y = 2/5 {
			replace _exp_group = `y' in `y'
			replace _`var' = _b[exp_group`y'usta] in `y'
			replace se_`var' = _se[exp_group`y'usta] in `y'
		}
	}
	
	keep if _exp_group != .
	keep _* se_*
	
	saveold "${results}exp_baseline_tables", replace
	
	*7. Tables formation
	*Note from the authors: step 1: for each file, stack the coefficients, so that the Std Err is under the coefficient
		*First generate a file of Std Err:
		
		use "${results}exp_baseline_tables", clear
		rename _exp_group expgr
		keep expgr se_*
		foreach var in $outcomes {
			rename se_`var' coef_`var'
		}
		g se = 1
		tempfile temp1
		saveold "${results}temp1", replace

		*Then generate a file of coeffs (the varnames in two files have to be the same)
		use "${results}exp_baseline_tables", clear
		rename _exp_group expgr
		foreach var in $outcomes {
			rename _`var' coef_`var'
		}
		g se = 0
		
		*Then stack them together
		append using "${results}temp1"
		
		*Sort in the desired order
		order expgr se
		sort expgr se
		drop se_*
		list 
		saveold "${results}coef_all", replace
		
	*Note from the authors: step 2: you have to stack all variables in one column for each group using the reshape command
		use "${results}coef_all", clear
		reshape long coef, i(expgr se) j(varname) string
		gen kind = 1
		replace kind = 2 if varname == "_lnhhinc" 
		replace kind = 3 if varname == "_lnhourly_ear"
		replace kind = 4 if varname == "_lnhours_usual" 
		replace kind = 5 if varname == "_lnweeks"
		replace kind = 6 if varname == "_hi_any" 
		replace kind = 7 if varname == "_hi_mcaid"
		replace kind = 8 if varname == "_hi_priv"
		replace kind = 9 if varname == "_foodstmp"
		replace kind = 10 if varname == "_lnstampval"
		replace kind = 11 if varname == "_poor"
		replace kind = 12 if varname == "_fullpart"
		replace kind = 13 if varname == "_nonempl"
		replace kind = 14 if varname == "_zeroweeks"
		sort kind expgr se
		rename coef coef_all //Note from the authors: rename this for each group
		g order = _n
		sort order
		saveold "${results}coef_all_long", replace
}

*** EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
*BY EDUCATION
{
	*1. Additional globals
	global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid hi_any hi_priv foodstmp lnstampval fullpart poor nonempl zeroweeks"
	
	*2. Load data, define sample and variables
	use "${data}", clear
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	gen nonempl = 1 - empl
	gen zeroweeks = (weeks == 0)
	
	*3. Collapse
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	collapse $outcomes (sum) cellsize [iw = wtsupp], by($collapse_exp)
	
	*4. Merge u-rate
	merge m:1 gradyear state using "${data_urate}", keep(3) nogen
	rename urateUSstate ustate
	
	*5. Interactions and controls
	*Note from the authors: generate the experience groups
	gen exp_group = 0
	replace exp_group = 1 if exp >= 0 & exp <= 3
	replace exp_group = 2 if exp >= 4 & exp <= 5
	replace exp_group = 3 if exp >= 6 & exp <= 7
	replace exp_group = 4 if exp >= 8 & exp <= 10
	replace exp_group = 5 if exp >= 11 & exp <= 15
	
	forvalues i = 1/5 {
		gen gp`i' = (exp_group == `i')
		gen exp_group`i'usta = gp`i'*ustate
	}
	
	gen year = grady + exp
	gen gystate = grady*100 + state
	gen _exp_group = 1 in 1
	
	*6. Regress and get coeffs
	forvalues x = 10(2)16 {
		foreach var of global outcomes {
			reg `var' exp_group1usta - exp_group5usta $FE_exp [aw = cellsize] if ED4 == `x', cluster(gystate)
			qui gen _`var'_`x' = _b[exp_group1usta] in 1
			qui gen se_`var'_`x' = _se[exp_group1usta] in 1
			
			qui forvalues y = 2/5 {
				replace _exp_group = `y' in `y'
				replace _`var'_`x' = _b[exp_group`y'usta] in `y'
				replace se_`var'_`x' = _se[exp_group`y'usta] in `y'
			}
		}
	}
	
	keep if _exp_group != .
	keep _* se_*
	
	saveold "${results}exp_baseline_educ_tables", replace
	
	*7. Tables formation
	*Note from the authors: step 1: for each file, stack the coefficients, so that the Std Err is under the coefficient
		*First generate a file of Std Err:
		use "${results}exp_baseline_educ_tables", clear
		rename _exp_group expgr
		keep expgr se_*
		forvalues x = 10(2)16 {
			foreach var in $outcomes {
				rename se_`var'_`x' coef_`var'_`x'
			}
		}
		g se = 1
		tempfile temp1
		saveold "${results}temp1", replace
		
		*Then generate a file of coeffs (the varnames in two files have to be the same)
		use "${results}exp_baseline_educ_tables", clear
		rename _exp_group expgr
		forvalues x = 10(2)16 {
			foreach var in $outcomes {
				rename _`var'_`x' coef_`var'_`x'
			}
		}
		g se = 0
		
		*Then stack them together
		append using "${results}temp1"
		
		*Sort in the desired order
		order expgr se
		sort expgr se
		drop se_*
		list 
		saveold "${results}coef_educ", replace

	*Note from the authors: step 2: you have to stack all variables in one column for each group using the reshape command
	use "${results}coef_educ", clear
	forvalues x = 10(2)16 {
		foreach var of global outcomes {
			rename coef_`var'_`x' coef_`x'_`var'
		}
	}		
	reshape long coef_10 coef_12 coef_14 coef_16, i(expgr se) j(varname) string 
	
	gen kind = 1
	replace kind = 2 if varname == "_lnhhinc" 
	replace kind = 3 if varname == "_lnhourly_ear"
	replace kind = 4 if varname == "_lnhours_usual" 
	replace kind = 5 if varname == "_lnweeks"
	replace kind = 6 if varname == "_hi_any" 
	replace kind = 7 if varname == "_hi_mcaid"
	replace kind = 8 if varname == "_hi_priv"
	replace kind = 9 if varname == "_foodstmp"
	replace kind = 10 if varname == "_lnstampval"
	replace kind = 11 if varname == "_poor"
	replace kind = 12 if varname == "_fullpart"
	replace kind = 13 if varname == "_nonempl"
	replace kind = 14 if varname == "_zeroweeks"
	sort kind expgr se
	g order = _n
	sort order
	saveold "${results}coef_educ_long", replace
}		

*** EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
*DEMOGRAPHIC GROUPS
{
	*1. Additional globals
	global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid hi_any hi_priv foodstmp lnstampval fullpart poor nonempl zeroweeks"
	global group1 "Male"
	global group2 "Female"
	global group3 "White"
	global group4 "Non-white"
	global groups "Male Female White Non-white"
	
	*2. Load data, define sample and variables
	forvalues x = 1/4 {
		use "${data}", clear
		
		gen Male = male
		gen Female = 1 - male
		gen White = white
		gen Nonwhite = 1 - white
		
		keep if ${group`x'} == 1
		
		gen yob = year - age
		replace gradyear = round(yob + 6 + eduyears)
		gen exp = year - gradyear
		
		keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
		
		gen ED4 = 10 if eduyears < 12
		replace ED4 = 12 if eduyears == 12
		replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
		replace ED4 = 16 if eduyears > 15 & eduyears < .
		
		gen nonempl = 1 - empl
		gen zeroweeks = (weeks == 0)
		
		*3. Collapse
		*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
		gen wtsupp = asecwt
		set more off
		
		collapse $outcomes (sum) cellsize [iw = wtsupp], by($collapse_exp)
		
		*4. Merge u-rate
		merge m:1 gradyear state using "${data_urate}", keep(3) nogen
		rename urateUSstate ustate
		
		*5. Interactions and controls
		*Note from the authors: generate the experience groups
		gen exp_group = 0
		replace exp_group = 1 if exp >= 0 & exp <= 3
		replace exp_group = 2 if exp >= 4 & exp <= 5
		replace exp_group = 3 if exp >= 6 & exp <= 7
		replace exp_group = 4 if exp >= 8 & exp <= 10
		replace exp_group = 5 if exp >= 11 & exp <= 15
		
		forvalues i = 1/5 {
			gen gp`i' = (exp_group == `i')
			gen exp_group`i'usta = gp`i'*ustate
		}
		
		gen year = grady + exp
		gen gystate = grady*100 + state
		gen _exp_group = 1 in 1
		
		*6. Regress and get coeffs
		foreach var of global outcomes {
			reg `var' exp_group1usta - exp_group5usta $FE_exp [aw = cellsize], cluster(gystate)
			qui gen _`var' = _b[exp_group1usta] in 1
			qui gen se_`var' = _se[exp_group1usta] in 1
			
			qui forvalues y = 2/5 {
				replace _exp_group = `y' in `y'
				replace _`var' = _b[exp_group`y'usta] in `y'
				replace se_`var' = _se[exp_group`y'usta] in `y'
			}
		}
		
		keep if _exp_group != .
		keep _* se_*
		saveold "${results}exp_baseline_${group`x'}_tables", replace
	}
	
	*7. Tables formation
	*Note from the authors: step 1: for each file, stack the coefficients, so that the Std Err is under the coefficient
		*First generate a file of Std Err:
		foreach x of global groups {
			use "${results}exp_baseline_`x'_tables", clear
			rename _exp_group expgr
			keep expgr se_*
			foreach var in $outcomes {
				rename se_`var' coef_`var'
			}
			g se = 1
			tempfile temp1
			saveold "${results}temp1", replace
			
			*Then generate a file of coeffs (the varnames in two files have to be the same)
			use "${results}exp_baseline_`x'_tables", clear
			rename _exp_group expgr
			foreach var in $outcomes {
				rename _`var' coef_`var'
			}
			g se = 0
			
			*Then stack them together
			append using "${results}temp1"
			
			*Sort in the desired order
			order expgr se
			sort expgr se
			drop se_*
			list 
			saveold "${results}coef_`x'", replace
		}
		
	*Note from the authors: step 2: you have to stack all variables in one column for each group using the reshape command
	use "${results}coef_Non-white", clear
	saveold "${results}coef_Non_white", replace
	
	global groups "Male Female White Non_white"
	foreach x of global groups {
		use "${results}coef_`x'", clear
		reshape long coef, i(expgr se) j(varname) string
		gen kind = 1
		replace kind = 2 if varname == "_lnhhinc"
		replace kind = 3 if varname == "_lnhourly_ear"
		replace kind = 4 if varname == "_lnhours_usual"
		replace kind = 5 if varname == "_lnweeks"
		replace kind = 6 if varname == "_hi_any"
		replace kind = 7 if varname == "_hi_mcaid"
		replace kind = 8 if varname == "_hi_priv"
		replace kind = 9 if varname == "_foodstmp"
		replace kind = 10 if varname == "_lnstampval"
		replace kind = 11 if varname == "_poor"
		replace kind = 12 if varname == "_fullpart"
		replace kind = 13 if varname == "_nonempl"
		replace kind = 14 if varname == "_zeroweeks"
		sort kind expgr se
		rename coef coef_`x' //Note from the authors: rename this for each group
		g order = _n
		sort order
		saveold "${results}coef_`x'_long", replace
	}
}
				
*** Merging the long tables of coefficients ***
use "${results}coef_all_long", clear
merge 1:1 order using "${results}coef_male_long"
tab _merge
drop _merge
sort order
merge 1:1 order using "${results}coef_Female_long"
tab _merge
drop _merge
sort order
merge 1:1 order using "${results}coef_White_long"
tab _merge
drop _merge
sort order
merge 1:1 order using "${results}coef_Non_white_long"
tab _merge
drop _merge
sort order
order varname expgr se coef_all coef_Male coef_Female coef_White coef_Non_white
saveold "${results}coef_long_demog", replace

use "${results}coef_long_demog", clear
merge 1:1 order using "${results}coef_educ_long"
tab _merge
drop _merge
sort order
order varname expgr se coef_all coef_Male coef_Female coef_White coef_Non_white coef_10 coef_12 coef_14 coef_16
saveold "${results}coef_long_baseline_spec", replace

*Save out separate coefficients into text files for excel tables
*Table 2
use "${results}coef_long_demog", clear
keep if varname == "_lnincwage" | varname == "_lnhhinc" | varname == "_lnhourly_ear" | varname == "_lnweeks"
drop if expgr == 5 //Note from the authors: drop group 11-15 since almost never significant
drop kind
drop order
outsheet using "${results}table_coef_demog_earnings.txt", replace

*Table 3
use "${results}coef_long_demog", clear
keep if varname == "_foodstmp" | varname == "_poor" | varname == "_hi_mcaid" | varname == "_hi_priv"
drop if expgr == 5 //Note from the authors: drop group 11-15 since almost never significant
drop kind
drop order
outsheet using "${results}table_coef_demog_welfare.txt", replace

*Table 4
use "${results}coef_educ_long", clear
keep if varname == "_lnincwage" | varname == "_lnhhinc" | varname == "_fullpart" | varname == "_lnweeks"
drop if expgr ==5 //Note from the authors: drop group 11-15 since almost never significant
drop kind
drop order
order varname expgr se
outsheet using "${results}table_coef_educ_earnings.txt", replace

*Table 5
use "${results}coef_educ_long", clear
keep if varname == "_foodstmp" | varname == "_poor" | varname == "_hi_mcaid" | varname == "_hi_priv"
drop if expgr == 5 //Note from the authors: drop group 11-15 since almost never significant
drop kind 
drop order
order varname expgr se
outsheet using "${results}table_coef_educ_welfare.txt", replace

cap log close //I had to add that
