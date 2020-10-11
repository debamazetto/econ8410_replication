***********************************
***   ECON8410 LABOR ECONOMICS  ***
***    REPLICATION ASSIGNMENT   ***
*** Débora Mazetto - 10/12/2020 ***
***********************************
*This do-file is part of the replication of the results of "Schwandt and Wachter (2018) 'Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets'".
*The do-file objective is to show the settings of the system and Stata used in the replication in the begining of each do-file.
*It was created by Lars Vilhuber and modified by me. For more informations, please access "https://github.com/AEADataEditor/replication-template".

local pwd : pwd //shows the current directory
global rootdir "`pwd'"
global logdir "${rootdir}\Log-files" //I changed the name from "logs" because that's how I prefer it
cap mkdir "$logdir" //makes new directory, I had to add " " because my directory contains spaces

local c_date = c(current_date)
local cdate = subinstr("`c_date'", " ", "_", .)
local c_time = c(current_time)
local ctime = subinstr("`c_time'", ":", "_", .)

cap log close //I had to add that in case I need to rerun the do-file
log using "$logdir/logfile_`cdate'-`ctime'.log", replace text //notes from the creator: it will provide some info about how and when the program was run. See "https://www.stata.com/manuals13/pcreturn.pdf#pcreturn"
local variant = cond(c(MP),"MP",cond(c(SE),"SE",c(flavor))) //notes from the creator: alternatively, you could use "local variant = cond(c(stata_version)>13,c(real_flavor),"NA")"

di "*** SYSTEM DIAGNOSTICS ***"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `variant'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"
di "**************************"

*Notes from the creator: install any packages locally (these names I kept).
capture mkdir "$rootdir/ado"
sysdir set PERSONAL "$rootdir/ado/personal"
sysdir set PLUS "$rootdir/ado/plus"
sysdir set SITE "$rootdir/ado/site"
sysdir

*Notes from the creator: add packages to the macro. Add required packages from SSC to this list.
local ssc_packages "" // local ssc_packages "estout boottest"
if !missing("`ssc_packages'") {
	foreach pkg in `ssc_packages' {
		dis "Installing `pkg'"
		ssc install `pkg', replace
	}
}

*Notes from the creator: install packages using net.
//net install yaml, from("https://raw.githubusercontent.com/gslab-econ/stata-misc/master/")
    
*Notes from the creator: other commands. After installing all packages, it may be necessary to issue the mata mlib index command.
mata: mata mlib index
set more off
