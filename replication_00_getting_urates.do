cd "C:\Users\Débora\Documents\Estudos\UGA\Classes\Fall 2020\ECON 8410 Labor Economics I\Replications"
do "Do-files\config.do"
***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to load data for states' unemployment rates. This data can be downloaded, as shown by the authors, at http://download.bls.gov/pub/time.series/la/.
*It was created by Schwandt and Wachter (original: "00_Getting_urates") and modified by me.

global dropbox "${rootdir}\Data" //rootdir comes from the config.do, I had to add that

clear //I had to add that in case I need to rerun the do-file
insheet using "${dropbox}\U rates\la.data.3.AllStatesS.txt" //I had to add the initial path defined in dropbox

gen stfips = real(substr(series_id,6,2))
gen month = real(substr(period,2,2))

gen meascode = real(substr(series_id,19,2))
keep if meascode == 3
rename value ur_s

*I had to add this part because the data imports unemployment rate as string variable
replace ur_s = "." if ur_s == "-"
destring ur_s, replace

keep stfips year month ur_s //if this line is used, then strips was substituted by stfips

bysort stfips year: egen u_annual = mean(ur_s)
collapse (mean) u_annual, by (stfips year)
rename stfips state
rename u_annual urate
rename year gradyear
rename urate urateUSstate
order state gradyear

save "${dropbox}\U rates\urateUSstate_1976_2016.dta", replace

cap log close //I had to add that
