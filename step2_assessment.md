# Replication: Assessment
## [JOLE-2019-37S1-0012] "Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets", Schwandt & von Wachter

## Summary
The replication refers to the paper Schwandt, Hannes and von Wachter, Till (2018) "Unlucky Cohorts: Estimating the Long-Term Effects of Entering the Labor Market in a Recession in Large Cross-Sectional Data Sets". _Journal of Labor Economics_, 2019, vol. 37, no. S1, [DOI](https://www.journals.uchicago.edu/doi/abs/10.1086/701046).

The paper uses public data - the Annual Social and Economic Supplement (ASEC) to the Current Population Survey (CPS), decennial census data, and American Community Survey (ACS) data - that can be easily obtained. Also, authors provide all the necessary do-files for the reproducibility of figures and tables in a very comprehensive way.

This assessment activity aims to evaluate the replicability of the article based on the materials provided by the authors. The authors provided the following files:
* Do-files for cleaning database and producing tables and figures;
* Word instructions for data sources ("Data_Sources_Overview"); and
* Word file with the list of programs ("List of Programs").

## Data
Although data is not provided, the authors provide a list with the source links and the replicator can easily download it at:
* **Unemployment rates**: at [Bureau of Labor Statistics](http://download.bls.gov/pub/time.series/la/) you can find.txt files to download the unemployment rates by month, year, and state for all 50 US states. Although the authors do not make it clear in the document which file should be downloaded, the replicator must obtain the "_la.data.3.AllStatesS_" file.
* **CPS data**: at [IPUMS-CPS](https://cps.ipums.org/cps/) you can select the variables and the sample extract following instructions in the "Data_Sources_Overview" file. However, some of the variables used by the authors are not specified and the replicator must be careful when running the programs. It is necessary to create an account and log in in order to download the sample extract.
* **US Census and American Community Survey**: at [IPUMS-Census](https://usa.ipums.org/usa/) you can select the variables and the sample extract following instructions in the "Data_Sources_Overview" file, and all the variables used by the authors are mentioned correctly. It is necessary to create an account and log in in order to download the sample extract and it is the same log in for the CPS source.

## Do-files
Authors provide 7 different do-files with the script for replication and they should be used in Stata. Every do-file is well commented and quite clear and organized.
* **Getting unemployment rates**: the file "00_Getting_urates" loads the unemployment rates using the file "_la.data.3.AllStatesS_". This file is complete and showed no problem to run, except that during the data import the unemployment rate came as a string variable and the replicator must destring it.
* **Cleaning CPS**: the file "01_Cleaning_CPS" cleans and prepares the CPS database to be used in the analysis, tables and figures. However, using this file the replicator will face the first relevant problem with the replication files: the missing variables that were not mentioned in the "Data_Sources_Overview". The replicator must go back to IPUMS in order to obtain these variables and I will provide in future a list with all necessary variables.
* **Figure 1**: the file "02_Figure_01" creates Figure 1 and is very complete and clear. Nonetheless, this file uses some databases that will be created by other do-files, so it should be run only after do-files "03_Figures_02_05_06_07_08_09_10_11_12_13_14" and "04_Figures_03_04". Also, it is necessary some command lines, such as install commands.
* **Figures 2, 5-14**: the file "03_Figures_02_05_06_07_08_09_10_11_12_13_14" creates Figure 2 and Figures 5 to 14. Although the file is organized, it is necessary to change some graph commands otherwise it will not compile the figures properly. Also, another important problem that I noticed is the absence of a weight variable that is used to weight observations for tables and figures. I had to go to IPUMS website to find a variable that could be the missing weight but, because the name of the variable is created by the authors, it cannot be assured that the variable I used is the same variable used by the authors.
* **Figures 3 and 4**: the file "04_Figures_03_04" creates Figures 3 and 4 and have the same features and problems as the previous file.
* **Table 1**: the file "05_Table_01" creates Table 1 and is organized and complete, I had no problem to run this script. However, it does not provide table in latex format, thus this is a good improvement for the files provided by the authors.
* **Tables 2-5**: the file "06_Tables_02_03_04_05" creates Tables 2 to 5 and have the same features and problems as the previous file.

## Conclusion
Giving all the materials provided by the authors, the replication of paper results is possible. Although changes must be done in almost every do-file, the problems encountered can be easily solved.
