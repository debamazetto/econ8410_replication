# Replication: Improvement
## [JOLE-2019-37S1-0012] "Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets", Schwandt & von Wachter

## Summary
The replication refers to the paper Schwandt, Hannes and von Wachter, Till (2018) "Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets". _Journal of Labor Economics_, 2019, vol. 37, no. S1, [DOI](https://www.journals.uchicago.edu/doi/abs/10.1086/701046).

The paper uses public data - the Annual Social and Economic Supplement (ASEC) to the Current Population Survey (CPS), decennial census data, and American Community Survey (ACS) data - that can be easily obtained. Also, authors provide all the necessary do-files for the reproducibility of figures and tables in a very comprehensive way.

I thank the authors for an excellent reproducible replication archive. I have a few additional, relatively minor issues, in order to bring the replication archive easier to for other people to replicate all figures and tables.

Thus, this file aims to suggest modifications and improvements to the original replication files.

## Data description
### Data sources
Although data is not provided, all data can be downloaded at:
* **Unemployment rates**: [Bureau of Labor Statistics](http://download.bls.gov/pub/time.series/la/), file "_la.data.3.AllStatesS_".
* **CPS data**: [IPUMS-CPS](https://cps.ipums.org/cps/). Although the authors provide a list with the variables and sample selection, some variables used in the do-files are missing. Thus, I prepared the file with the complete [list of variables](https://github.com/debamazetto/econ8410_replication/blob/master/variables.xlsx) for CPS.
* **US Census and American Community Survey**: [IPUMS-Census](https://usa.ipums.org/usa/). The authors provide a list with the variables and sample selection and I compiled the Census list of variables along with CPS, you can find it in the [same document](https://github.com/debamazetto/econ8410_replication/blob/master/variables.xlsx).

For both CPS and Census, it is necessary to register at IPUMS website, without any fees.

### Files and requirements
It is not necessary specific system requirements to run the do-files, but only Stata available to reproduce all figures and tables. Each do-file identifies correctly which figure or table will be produced with the following code.

The do-files [00 Getting U rates](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_00_getting_urates.do) and [01 Cleaning CPS](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_01_cleaning_cps.do) allow you to obtain the two main databases for the replication of most of the tables. Those do-files are originally created by Schwandt & von Wachter and were modified by me to fix small mistakes, such as missing variables and graph specification.

All do-files were well commented and organized, what made the replication job easy. However, although the authors enumerated the do-files, the order for replication from scratch should not follow the numeration of the files. Rather, for replication, should proceed with the following files:
* 00 Getting U rates
* 01 Cleaning CPS
* 03 Figures 2, 5-14
* 04 Figures 3 and 4
* 02 Figure 1
* 05 Table 1
* 06 Tables 2-5

I added two important important features to the do-files:
1. Directory creation: [initial code](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/config.do) creates folders for data, results, and log-files. However, it is important to be careful to where each data file is saved and substitute correctly the path in the beginning of each code.
2. Log-files: [initial code](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/config.do) also creates log-files for each do-file. This is important for backup and comparisson in case the code needs to be changed.

## Replication steps
In order for the replication occurs correctly, the user should follow these instructions:
1. Create all directories necessary for the replication. Please, follow the exact same stated bellow, except for the root folder, that can be of your choice. This will make it easier to change only few code lines in each do-file.
  * Root: where all other folders will be saved;  
  * Data: folder where you must save data files. Inside this folder, create the following folders:  
    ** Census: save the Census data here;  
    ** CPS: save the CPS data here;  
    ** U rates: save the unemployment rate data here;  
    ** Results: all the results (figures, tables, final databases) will be saved here automatically.  
  * Do-files: download all do-files that are in the [repository folder](https://github.com/debamazetto/econ8410_replication/blob/master/do-files) and save in this folder.  
  * Log-files: all log-files will be saved here automatically.  
2. Download all data to the correspondent folders. Download the unemployment rates in .txt and CPS and Census in .dta formats.  
> Do NOT detail things like "I save them on my Desktop".
> DO describe actions   that you did  as per instructions ("I added a config.do")
> DO describe any other actions you needed to do ("I had to make changes in multiple programs"), without going into detail (the commit log can provide that information)

Example:

1. Downloaded code from URL provided.
2. Downloaded data from URL indicated in the README. A sign-up was required (not indicated in README)
3. Added the config.do generating system information, but commented out log creation, as author already creates log files.
4. Ran code as per README, but the third step did not work.
5. Made changes to the way the third step is run to get it to work.

Findings
--------

> INSTRUCTIONS: Describe your findings both positive and negative in some detail, for each **Data Preparation Code, Figure, Table, and any in-text numbers**. You can re-use the Excel file created under *Code Description*. When errors happen, be as precise as possible. For differences in figures, provide both a screenshot of what the manuscript contains, as well as the figure produced by the code you ran. For differences in numbers, provide both the number as reported in the manuscript, as well as the number replicated. If too many numbers, contact your supervisor.

### Data Preparation Code

Examples:

- Program `1-create-data.do` ran without error, output expected data
- Program `2-create-appendix-data.do` failed to produce any output.

### Tables

Examples:

- Table 1: Looks the same
- Table 2: (contains no data)
- Table 3: Minor differences in row 5, column 3, 0.003 instead of 0.3

### Figures

> INSTRUCTIONS: Please provide a comparison with the paper when describing that figures look different. Use a screenshot for the paper, and the graph generated by the programs for the comparison. Reference the graph generated by the programs as a local file within the repository.

Example:

- Figure 1: Looks the same
- Figure 2: no program provided
- Figure 3: Paper version looks different from the one generated by programs:

Paper version:
![Paper version](template/dog.jpg)

Figure 3 generated by programs:

![Replicated version](template/odie.jpg)

### In-Text Numbers

> INSTRUCTIONS: list page and line number of in-text numbers. If ambiguous, cite the surrounding text, i.e., "the rate fell to 52% of all jobs: verified".

[ ] There are no in-text numbers, or all in-text numbers stem from tables and figures.

[ ] There are in-text numbers, but they are not identified in the code

- Page 21, line 5: Same


Classification
--------------

> INSTRUCTIONS: Make an assessment here.
>
> Full reproduction can include a small number of apparently insignificant changes in the numbers in the table. Full reproduction also applies when changes to the programs needed to be made, but were successfully implemented.
>
> Partial reproduction means that a significant number (>25%) of programs and/or numbers are different.
>
> Note that if any data is confidential and not available, then a partial reproduction applies. This should be noted in the Reasons
>
> Note that when all data is confidential, it is unlikely that this exercise should have been attempted.
>
> Failure to reproduce: only a small number of programs ran successfully, or only a small number of numbers were successfully generated (<25%)

- [ ] full reproduction
- [ ] full reproduction with minor issues
- [ ] partial reproduction (see above)
- [ ] not able to reproduce most or all of the results (reasons see above)

### Reason for incomplete reproducibility

> INSTRUCTIONS: mark the reasons here why full reproduciblity was not achieved, and enter this information in JIRA

- [ ] `Discrepancy in output` (either figures or numbers in tables or text differ)
- [ ] `Bugs in code`  that  were fixable by the replicator (but should be fixed in the final deposit)
- [ ] `Code missing`, in particular if it  prevented the replicator from completing the reproducibility check
- [ ] `Code not functional` is more severe than a simple bug: it  prevented the replicator from completing the reproducibility check
- [ ] `Software not available to replicator`  may happen for a variety of reasons, but in particular (a) when the software is commercial, and the replicator does not have access to a licensed copy, or (b) the software is open-source, but a specific version required to conduct the reproducibility check is not available.
- [ ] `Insufficient time available to replicator` is applicable when (a) running the code would take weeks or more (b) running the code might take less time if sufficient compute resources were to be brought to bear, but no such resources can be accessed in a timely fashion (c) the replication package is very complex, and following all (manual and scripted) steps would take too long.
- [ ] `Data missing` is marked when data *should* be available, but was erroneously not provided, or is not accessible via the procedures described in the replication package
- [ ] `Data not available` is marked when data requires additional access steps, for instance purchase or application procedure. 
