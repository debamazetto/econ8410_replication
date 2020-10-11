cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to produce "Figure 2, 5 to 14".
*It was created by Schwandt and Wachter (original: "03_Figures_02_05_06_07_08_09_10_11_12_13_14") and modified by me.

*Note from the authors: this code generates the figures for the cohorts paper of Schwandt and von Wachter; the outcome variables come from the March files of IPUMS CPS; the main right handside variables are the state unemployment rates at graduation age or age 18.


*** Program produces figures 2, 5, 6, 7, 8, 9, 10, 11, 12,13, 14 ***
clear
set more off
cap ssc install grc1leg

*** PRELIMINARIES (Always run this part of the code; these globals are used below) ***
*Directories
global dropbox "${rootdir}\Data"

global data "${dropbox}\merged_precollapse_1976_2016.dta"
global data_urate "${dropbox}\U rates\urateUSstate_1976_2016.dta"
global results "${dropbox}\Results"

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
global outcomes "lnhourly_ear lnincwage lnhh_own lnweeks lnhours_usual foodstmp hi_mcaid"

*Graph options
global graph1 "connect(l) color(red) lwidth(medthick) msymbol(T) msize(large)"
global graph2 "connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(medium)"
global graphoptions "graphregion(color(white)) xlabel(1(2)15) xtitle("Years since Graduation", size(large)) yline(0, lcolor(black)) xlabel(,labsize(large)) ylabel(,labsize(medlarge))"
global graphoptionsage "graphregion(color(white)) xlabel(19(2)33) xtitle("Age", size(large)) yline(0, lcolor(black)) xlabel(,labsize(large)) ylabel(,labsize(large))"

*Comprehensive list of outcomes
*Note from the authors: white black hourly_earnings lnhourly_ear male married eduy hi_mcaid hcovpriv lnincwage lnhh_own pos_wage pos_earn pos_inc unempl NILF empl lnweeks lnhours lnhours_usual lnhourwage lnearnweek migstate move1 move5 lnincss lnincssi lnincwelfr lnincgov lnincdisab lnincunemp lnincasist lnstampval foodstmp college colldeg highschool morehs hi_any

*** BASELINE: EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
{
	*1. Additional globals
	global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid foodstmp fullpart poor lnstampval hi_priv hi_any  unempl incwage"
	global graphoptions "graphregion(color(white)) xlabel(1(2)15) xtitle("Years since Graduation", size(large)) yline(0, lcolor(black)) xlabel(,labsize(large)) ylabel(,labsize(medium))"
	
	*2. Load data, define sample and variables
	use "${data}", clear
	
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	*3. Collapse
	collapse $outcomes (sum) cellsize [iw = wtsupp], by($collapse_exp) //the variable "wtsupp" does not exist in any database and I cannot retrieve it
	
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
	
	*7. Figures
	*Figure 2
		twoway (scatter _lnincwage _exp, $graph1) ///
			(scatter _lnhhinc _exp, $graph2), ///
			legend( order(1 "Annual Earnings" 2 "Annual Household Income") symxsize(6)) ytitle("Effect on log earnings/income", size(large)) ///
			saving("${results}\exp_inc", replace) $graphoptions
		graph export "${results}\figure2.png", replace //I added this line to save graphs as image
	
	*Figure 5
		twoway (scatter _lnhourly_ear _exp, $graph1) ///
			(scatter _lnhours_usual _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)) ///
			(scatter _lnweeks _exp, connect(l) lpattern(dash_dot) lwidth(medthick) color(green) msymbol(Dh) msize(large)), ///
			legend(order(1 "Hourly Earnings" 2 "Usual Hours Worked" 3 "Weeks Employed") symxsize(6)) ytitle("Effect on log outcome", size(large)) ///
			saving("${results}\exp_incplus", replace) $graphoptions
		graph export "${results}\figure5.png", replace //I added this line to save graphs as image
	
	*Figure 6
		twoway (scatter _hi_mcaid _exp, $graph1) ///
			(scatter _foodstmp _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)), ///
			legend(order(1 "Medicaid" 2 "Foodstamps") symxsize(6)) ytitle("Effect on fraction receiving welfare", size(large)) ///
			saving("${results}\exp_welfare", replace) $graphoptions
		graph export "${results}\figure6.png", replace //I added this line to save graphs as image
	
	keep if _exp != .
	keep _* se_*
	
	saveold "${results}\exp_baseline", replace
}

*** EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
*BY EDUCATION
global graphoptions "graphregion(color(white)) xlabel(1(2)15) xtitle("Years since Graduation", size(medium))  yline(0, lcolor(black))  xlabel(,labsize(large)) ylabel(,labsize(medium))"

{
	*1. Additional globals
	global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid foodstmp fullpart poor lnstampval hi_priv hi_any"
	
	*2. Load data, define sample and variables
	use "${data}", clear
	
	*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
	gen wtsupp = asecwt
	set more off
	
	gen yob = year - age
	replace gradyear = round(yob + 6 + eduyears)
	gen exp = year - gradyear
	
	keep if inrange(age,16,39) & inrange(exp,${minexp},${maxexp}) & inrange(gradyear,${mingradyear},${maxgradyear}) & inrange(year,${minyear},${maxyear})
	
	gen ED4 = 10 if eduyears < 12
	replace ED4 = 12 if eduyears == 12
	replace ED4 = 14 if eduyears >= 13 & eduyears <= 15
	replace ED4 = 16 if eduyears > 15 & eduyears < .
	
	*3. Collapse
	collapse $outcomes (sum) cellsize [iw = wtsupp], by($collapse_exp)
	
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
	forvalues x = 10(2)16 {
		foreach var of global outcomes {
			reg `var' exp${minexp}usta - exp${maxexp}usta $FE_exp [aw = cellsize] if ED4 == `x', cluster(gystate)
			qui gen _`var'_`x' = _b[exp1usta] in 1
			qui gen se_`var'_`x' = _se[exp1usta] in 1
			
			qui forvalues y = 2/$maxexp {
				replace _exp = `y' in `y'
				replace _`var'_`x' = _b[exp`y'usta] in `y'
				replace se_`var'_`x' =_se[exp`y'usta] in `y'
			}
		}
	}
	
	*7. Figures
		*Figure 8	
			twoway (scatter _lnincwage_10 _exp, $graph1) ///
				(scatter _lnhhinc_10 _exp , $graph2), legend(order(1 "Earnings" 2 "Household Income") symxsize(6))  ytitle("Effect on log income", size(large)) title("<12 years of schooling", size(4)) $graphoptions saving("${results}\lnincwage_edu1", replace)
			
			twoway (scatter _lnincwage_12 _exp, $graph1) ///
				(scatter _lnhhinc_12 _exp , $graph2 ), legend(off) title("12 years of schooling", size(4)) $graphoptions saving("${results}\lnincwage_edu2", replace)
			
			twoway (scatter _lnincwage_14 _exp, $graph1) ///
				(scatter _lnhhinc_14 _exp, $graph2), legend(off) title(" 13-15 years of schooling", size(4)) $graphoptions saving("${results}\lnincwage_edu3", replace)
			
			twoway (scatter _lnincwage_16 _exp, $graph1) ///
				(scatter _lnhhinc_16 _exp, $graph2), legend(off) title("16+ years of schooling", size(4)) $graphoptions saving("${results}\lnincwage_edu4", replace)
			
			grc1leg "${results}\lnincwage_edu1.gph" "${results}\lnincwage_edu2.gph" "${results}\lnincwage_edu3.gph" "${results}\lnincwage_edu4.gph", ///
				legendfrom("${results}\lnincwage_edu1.gph") graphregion(color(white)) ycommon saving("${results}\exp_lnincwage_byEduc", replace) 
			graph export "${results}\figure8.png", replace //I added this line to save graphs as image
			
			erase "${results}\lnincwage_edu1.gph"
			erase "${results}\lnincwage_edu2.gph"
			erase "${results}\lnincwage_edu3.gph"
			erase "${results}\lnincwage_edu4.gph"
		
		*Figure 10
		twoway (scatter _lnhourly_ear_10 _exp, $graph1) ///
			(scatter _lnhours_usual_10 _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)) ///
			(scatter _lnweeks_10 _exp, connect(l) lpattern(dash_dot) lwidth(medthick) color(green) msymbol(Dh) msize(large)), ///
			nodraw legend(order(1 "Hourly Earnings" 2 "Usual Hours Worked" 3 "Weeks Employed") symxsize(6)) ytitle("Effect on log outcome", size(large)) title("<12 years of schooling", size(4)) ///
			saving("${results}\exp_incplus_edu1", replace) $graphoptions
		
		twoway (scatter _lnhourly_ear_12 _exp, $graph1) ///
			(scatter _lnhours_usual_12 _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)) ///
			(scatter _lnweeks_12 _exp, connect(l) lpattern(dash_dot) lwidth(medthick) color(green) msymbol(Dh) msize(large)), ///
			nodraw legend(off) title("12 years of schooling", size(4)) ///
			saving("${results}\exp_incplus_edu2", replace) $graphoptions
		
		twoway (scatter _lnhourly_ear_14 _exp, $graph1) ///
			(scatter _lnhours_usual_14 _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)) ///
			(scatter _lnweeks_14 _exp, connect(l) lpattern(dash_dot) lwidth(medthick) color(green) msymbol(Dh) msize(large)), ///
			nodraw legend(off) title("13-15 years of schooling", size(4)) ///
			saving("${results}\exp_incplus_edu3", replace) $graphoptions
		
		twoway (scatter _lnhourly_ear_16 _exp, $graph1) ///
			(scatter _lnhours_usual_16 _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)) ///
			(scatter _lnweeks_16 _exp, connect(l) lpattern(dash_dot) lwidth(medthick) color(green) msymbol(Dh) msize(large)), ///
			nodraw legend(off) title("16+ years of schooling", size(4)) ///
			saving("${results}\exp_incplus_edu4", replace) $graphoptions
		
		grc1leg "${results}\exp_incplus_edu1.gph" "${results}\exp_incplus_edu2.gph" "${results}\exp_incplus_edu3.gph" "${results}\exp_incplus_edu4.gph", ///
			legendfrom("${results}\exp_incplus_edu1.gph") graphregion(color(white)) ycommon saving("${results}\exp_incplus_byEduc", replace)
		graph export "${results}\figure10.png", replace //I added this line to save graphs as image
		
		erase "${results}\exp_incplus_edu1.gph" 
		erase "${results}\exp_incplus_edu2.gph" 
		erase "${results}\exp_incplus_edu3.gph" 
		erase "${results}\exp_incplus_edu4.gph"
		
		*Figure 12
		twoway (scatter _hi_mcaid_10 _exp, $graph1) ///
			(scatter _foodstmp_10 _exp, $graph2), nodraw legend(order(1 "Medicaid" 2 "Foodstamps") symxsize(6)) ytitle("Effect on welfare", size(large)) title("<12 years of schooling", size(4)) $graphoptions saving("${results}\_hi_mcaid_edu1", replace)
		
		twoway (scatter _hi_mcaid_12 _exp, $graph1) ///
			(scatter _foodstmp_12 _exp, $graph2), nodraw legend(off) title("12 years of schooling", size(4)) $graphoptions saving("${results}\_hi_mcaid_edu2", replace)
		
		twoway (scatter _hi_mcaid_14 _exp, $graph1) ///
			(scatter _foodstmp_14 _exp, $graph2), nodraw legend(off) title("13-15 years of schooling", size(4)) $graphoptions saving("${results}\_hi_mcaid_edu3", replace)
		
		twoway (scatter _hi_mcaid_16 _exp, $graph1) ///
			(scatter _foodstmp_16 _exp, $graph2), nodraw legend(off) title("16+ years of schooling", size(4)) $graphoptions saving("${results}\_hi_mcaid_edu4", replace)
		
		grc1leg "${results}\_hi_mcaid_edu1.gph" "${results}\_hi_mcaid_edu2.gph" "${results}\_hi_mcaid_edu3.gph" "${results}\_hi_mcaid_edu4.gph", ///
			legendfrom("${results}\_hi_mcaid_edu1.gph") graphregion(color(white)) ycommon saving("${results}\exp_hi_mcaid_byEduc", replace)
		graph export "${results}\figure12.png", replace //I added this line to save graphs as image
		
		erase "${results}\_hi_mcaid_edu1.gph"
		erase "${results}\_hi_mcaid_edu2.gph"
		erase "${results}\_hi_mcaid_edu3.gph"
		erase "${results}\_hi_mcaid_edu4.gph"
		
		keep if _exp != .
		keep _* se_*
		
		saveold "${results}\exp_baseline_educ", replace
}		

*Figure 14
twoway (scatter _poor_10 _exp, $graph1) ///
	(scatter _poor_12 _exp, $graph2) ///
	(scatter _poor_14 _exp, connect(l) color(green) lwidth(medthick) lpattern(longdash_dot) msymbol(O) msize(large)) ///
	(scatter _poor_16 _exp, connect(l) color(yellow) lwidth(medthick) lpattern(shortdash_dot) msymbol(D) msize(large)), $graphoptions ///
	ytitle("Effect on fraction poor", size(large)) legend( order(1 "Less than 12" 2 "Equal to 12" 3 "Between 13 and 15" 4 "Over 15"))
graph export "${results}\figure14.png", replace //I added this line to save graphs as image

*** EFFECTS OF UNEMPLOYMENT RATE AT GRADAUATION AGE AT STATE OF RESIDENCE ***
*DEMOGRAPHIC GROUPS
global graphoptions "graphregion(color(white)) xlabel(1(2)15) xtitle("Years since Graduation", size(large)) yline(0, lcolor(black)) xlabel( ,labsize(large)) ylabel( ,labsize(medium))"

{
	*1. Additional globals
	global outcomes "lnincwage lnhhinc lnhourly_ear lnhours_usual lnweeks hi_mcaid foodstmp fullpart poor lnstampval hi_priv hi_any"
	global group1 "Male"
	global group2 "Female"
	global group3 "White"
	global group4 "Non-white"
	
	*2. Load data, define sample and variables
	forvalues x = 1/4 {
		use "${data}", clear
		
		*The authors use "wtsupp" for weights. I had to go online to find out that this is the same as "asecwt" in this case.
		gen wtsupp = asecwt
		set more off
		
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
		
		*3. Collapse
		collapse $outcomes (sum) cellsize [iw = wtsupp], by($collapse_exp)
		
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
		
		saveold "${results}\exp_baseline_${group`x'}", replace
		
		*7. Figures
		twoway (scatter  _lnincwage _exp , $graph1 ) ///
			(scatter  _lnhhinc _exp , $graph2 ),  ///
			legend( order(1 "Annual Earnings" 2 "Annual Household Income") symxsize(6)) ///
			title("${group`x'}", size(4)) saving("${results}\_inc_${group`x'}", replace) $graphoptions nodraw
		
		twoway (scatter _lnhourly_ear _exp, $graph1) ///
			(scatter _lnhours_usual _exp, connect(l) lpattern(dash) lwidth(medthick) color(blue) msymbol(S) msize(large)) ///
			(scatter _lnweeks _exp, connect(l) lpattern(dash_dot) lwidth(medthick) color(green) msymbol(Dh) msize(large)), ///
			legend(order(1 "Hourly Earnings" 2 "Usual Hours Worked" 3 "Weeks Employed") symxsize(6)) ///
			title("${group`x'}", size(4)) saving("${results}\_incplus_${group`x'}", replace) $graphoptions nodraw
		
		twoway (scatter _hi_mcaid _exp, $graph1) ///
			(scatter _foodstmp _exp, $graph2), ///
			legend(order(1 "Medicaid" 2 "Foodstamps") symxsize(6)) ///
			title("${group`x'}", size(4)) saving("${results}\_welfare_${group`x'}", replace) $graphoptions nodraw
		
	}
	
	*Figure 7
	grc1leg "${results}\_inc_Male.gph" "${results}\_inc_Female.gph" "${results}\_inc_White.gph" "${results}\_inc_Non-white.gph", ///
		legendfrom("${results}\_inc_Male.gph") graphregion(color(white)) ycommon saving("${results}\exp_inc_byDemo", replace)
	graph export "${results}\figure7.png", replace //I added this line to save graphs as image
	
	erase "${results}\_inc_Male.gph"
	erase "${results}\_inc_Female.gph"
	erase "${results}\_inc_White.gph"
	erase "${results}\_inc_Non-white.gph"
	
	*Figure 9
	grc1leg "${results}\_incplus_Male.gph" "${results}\_incplus_Female.gph" "${results}\_incplus_White.gph" "${results}\_incplus_Non-white.gph", ///
		legendfrom("${results}\_incplus_Male.gph") graphregion(color(white)) ycommon saving("${results}\exp_incplus_byDemo", replace)
	graph export "${results}\figure9.png", replace //I added this line to save graphs as image
	
	erase "${results}\_incplus_Male.gph"
	erase "${results}\_incplus_Female.gph"
	erase "${results}\_incplus_White.gph"
	erase "${results}\_incplus_Non-white.gph"
	
	*Figure 11
	grc1leg "${results}\_welfare_Male.gph" "${results}\_welfare_Female.gph" "${results}\_welfare_White.gph" "${results}\_welfare_Non-white.gph", ///
		legendfrom("${results}\_welfare_Male.gph") graphregion(color(white)) ycommon saving("${results}\exp_welfare_byDemo", replace)
	graph export "${results}\figure11.png", replace //I added this line to save graphs as image
	
	erase "${results}\_welfare_Male.gph"
	erase "${results}\_welfare_Female.gph"
	erase "${results}\_welfare_White.gph"
	erase "${results}\_welfare_Non-white.gph"
	
	keep if _exp != .
	keep _* se_*
}

use "${results}\exp_baseline_Male", clear
drop if _exp == .
keep _exp _poor _fullpart
rename _poor _poor_male
rename _fullpart _fullpart_male
saveold "${results}\crap1", replace

use "${results}\exp_baseline_Female", clear
drop if _exp == .
keep _exp _poor _fullpart
rename _poor _poor_female 
rename _fullpart _fullpart_female
saveold "${results}\crap2", replace

use "${results}\exp_baseline_White", clear
drop if _exp == .

keep _exp _poor _fullpart
rename _poor _poor_white
rename _fullpart _fullpart_white
saveold "${results}\crap3", replace

use "${results}\exp_baseline_Non-white", clear
drop if _exp == .

keep _exp _poor _fullpart
rename _poor _poor_non_white
rename _fullpart _fullpart_non_white
saveold "${results}\crap4", replace

use "${results}\crap1", clear
merge 1:1 _exp using "${results}\crap2"
drop _merge
merge 1:1 _exp using "${results}\crap3"
drop _merge
merge 1:1 _exp using "${results}\crap4"
drop _merge

*Figure 13
twoway (scatter _poor_male _exp, $graph1) ///
	(scatter _poor_female _exp, $graph2) ///
	(scatter _poor_white _exp, connect(l) color(green) lwidth(medthick) lpattern(shortdash_dot) msymbol(O) msize(large)) ///
	(scatter _poor_non_white _exp, connect(l) color(yellow) lwidth(medthick) lpattern(longdash_dot) msymbol(D) msize(large)), $graphoptions ///
	ytitle("Effect on fraction poor", size(large)) legend( order(1 "Male" 2 "Female" 3 "White" 4 "Non-white"))
graph export "${results}\figure13.png", replace //I added this line to save graphs as image

cap log close //I had to add that
