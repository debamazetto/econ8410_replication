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
Those were the steps I followed for the replication:
1. Downloaded code provided by the authors.
2. Downloaded data from URL indicated in the "Data_Sources_Overview". A sign-up was required (not indicated in the beginning).
3. Added the config.do generating system information since author's do-files do not create log-files.
4. Ran code as per "List of Programs" and the numeration of the do-files. However, on do-file 01, it did not work because there were some variables that were not listed in the "Data_Sources_Overview".
5. Downloaded the file again with all the necessary variables.
6. Noticed the order to run the code should not follow the numeration in the files because some modified databases used in the first do-files are created only by late do-files. That is way the order is changed.
7. Noticed one variable was missing ("wtsupp"). I could not find this variable in the CPS website but, looking at the metadata files, I concluded this variable is the same as "asecwt" giving the CPS supplement authors are using.
8. Made changes necessary to the code, such as installing some commands and graph commands that were not correct.

Thus, in order for the replication occurs correctly, the user should follow these instructions:
1. Create all directories necessary for the replication. Please, follow the exact same stated bellow, except for the root folder, that can be of your choice. This will make it easier to change only few code lines in each do-file.  
  * Root: where all other folders will be saved;  
  * Data: folder where you must save data files. Inside this folder, create the following folders:  
    * Census: save the Census data here;  
    * CPS: save the CPS data here;  
    * U rates: save the unemployment rate data here;  
    * Results: all the results (figures, tables, final databases) will be saved here automatically.  
  * Do-files: download all do-files that are in the [repository folder](https://github.com/debamazetto/econ8410_replication/blob/master/do-files) and save in this folder.  
  * Log-files: all log-files will be saved here automatically.  
2. Download all data to the correspondent folders. Download the unemployment rates in .txt and CPS and Census in .dta formats.  
3. Run each do-file in the following order. Do not forget to change the path on the beginning of each do-file to match your root directory.  
 * [00 Getting U rates](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_00_getting_urates.do)
 * [01 Cleaning CPS](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_01_cleaning_cps.do)
 * [03 Figures 2, 5-14](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_03_figures_02_05_06_07_08_09_10_11_12_13_14.do)
 * [04 Figures 3 and 4](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_04_figures_03_04.do)
 * [02 Figure 1](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_02_figure_01.do)
 * [05 Table 1](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_05_table_01.do)
 * [06 Tables 2-5](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_06_tables_02_03_04_05.do)

## Findings
### Data preparation code
As mentioned before, the do-files are organized and well commented by the authors. The replication of data cleaning, however, was harder than expected because some variables were not mentioned by the authors in the document "Data_Sources_Overview". So I had to go back to the original source a couple of times to add those variables to the list.

Particularly, the cleaning of the Census data needs a database that is created by do-files [03](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_03_figures_02_05_06_07_08_09_10_11_12_13_14.do) and [04](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_04_figures_03_04.do). Thus, the numeration of the do-files is misleading in a way.

Solved these deficiencies, the data preparation code ran smoothly.

### Figures
The figures do-files are well commented but one important error occured: I could not find the correct weight variable to created the tables and figures. Thus, I went to the IPUMS website to find out that the variable "wtsupp" in the authors do-file could be actually "asecwt". I created this variable in each do-file whenever it was necessary. But, as you can see from figures bellow, there is a small different in the results and this can be because of this missing information.

Besides that, when small erros in the graphs code, the result is very close to the original and all figures could be reproduced.

**Figure 1 - Paper version**  
![Figure 1 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure1.PNG)

**Figure 1 - Replication**  
![Figure 1 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure1.png)

**Figure 2 - Paper version**  
![Figure 2 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure2.PNG)

**Figure 2 - Replication**  
![Figure 2 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure2.png)

**Figure 3 - Paper version**  
![Figure 3 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure3.PNG)

**Figure 3 - Replication**  
![Figure 3 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure3.png)

**Figure 4 - Paper version**  
![Figure 4 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure4.PNG)

**Figure 4 - Replication**  
![Figure 4 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure4.png)

**Figure 5 - Paper version**  
![Figure 5 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure51.PNG)

**Figure 5 - Replication**  
![Figure 5 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure5.png)

**Figure 6 - Paper version**  
![Figure 6 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure6.PNG)

**Figure 6 - Replication**  
![Figure 6 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure6.png)

**Figure 7 - Paper version**  
![Figure 7 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure7.PNG)

**Figure 7 - Replication**  
![Figure 7 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure7.png)

**Figure 8 - Paper version**  
![Figure 8 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure8.PNG)

**Figure 8 - Replication**  
![Figure 8 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure8.png)

**Figure 9 - Paper version**  
![Figure 9 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure9.PNG)

**Figure 9 - Replication**  
![Figure 9 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure9.png)

**Figure 10 - Paper version**  
![Figure 10 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure10.PNG)

**Figure 10 - Replication**  
![Figure 10 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure10.png)

**Figure 11 - Paper version**  
![Figure 11 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure11.PNG)

**Figure 11 - Replication**  
![Figure 11 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure11.png)

**Figure 12 - Paper version**  
![Figure 12 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure12.PNG)

**Figure 12 - Replication**  
![Figure 12 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure12.png)

**Figure 13 - Paper version**  
![Figure 13 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure13.PNG)

**Figure 13 - Replication**  
![Figure 13 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure13.png)

**Figure 14 - Paper version**  
![Figure 14 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_figure14.PNG)

**Figure 14 - Replication**  
![Figure 14 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/figure14.png)

### Tables
The table do-files were the last ones I ran and no error occured. The only missing part in do-files [05](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_05_table_01.do) and [06](https://github.com/debamazetto/econ8410_replication/blob/master/do-files/replication_06_tables_02_03_04_05.do) were a proper code that allows exporting tables to Latex, for example. All tables are saved in .txt format, so, in the absence of a better way to solve it, I prepared the ["table generator"](https://github.com/debamazetto/econ8410_replication/blob/master/tables.xlsx) file to help future replications.

However, the results I obtained with the same code and data were not exactly the same as shown in the paper.

**Table 1 - Paper version**  
![Table 1 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_table1.PNG)

**Table 1 - Replication**  
![Table 1 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/table1.png)

**Table 2 - Paper version**  
![Table 2 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_table2.PNG)

**Table 2 - Replication**  
![Table 2 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/table2.png)

**Table 3 - Paper version**  
![Table 3 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_table3.PNG)

**Table 3 - Replication**  
![Table 3 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/table3.png)

**Table 4 - Paper version**  
![Table 4 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_table4.PNG)

**Table 4 - Replication**  
![Table 4 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/table4.png)

**Table 5 - Paper version**  
![Table 5 - Paper version](https://github.com/debamazetto/econ8410_replication/blob/master/original/original_table5.PNG)

**Table 5 - Replication**  
![Table 5 - Replication](https://github.com/debamazetto/econ8410_replication/blob/master/results/table5.png)

## Classification
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
