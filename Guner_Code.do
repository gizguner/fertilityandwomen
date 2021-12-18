*************************************************************
*                    DATA PROJECT	                        *
* 	Gizem Guner                     			            * 
*	Women's Fertility Decisions, Education & Occupation		*
*					in Turkey 		 						*
*************************************************************

clear
set more off, permanently
set maxvar 30000
log using projectfinal.log
cd "C:\Users\LENOVO\Desktop\" 

/*PART 1: DHS 2013 Sample*/
/* DATA CLEANING*///////////////////////////////////////////

use "C:\Users\LENOVO\Desktop\sinan\DHS13\TRIR4ADT\TRIR4AFL.DTA"

rename v012 age
rename v501 married
drop if married!=1
rename v213 preg
drop if preg==1 /*exclude pregnant women*/
gen agesq= age*age /*age square for nonlinearity*/

/*dependent variable*/

gen modern=.
replace modern=1 if v364==1
replace modern=0 if modern!=1

gen birthcontrol=.
replace birthcontrol=1 if v364==1 | v364==2
replace birthcontrol=0 if birthcontrol!=1
tab birthcontrol 

/*independent variables*/
/*2.A. individual observed characteristics*/
*************ethnicity***************************

gen ethnicity=. /*ethnicity: 0= Turkish, 1=Kurdish, 2=Arabic, 3=Other */
replace ethnicity=0 if s116==1
replace ethnicity=1 if s116==2
replace ethnicity=2 if s116==3
replace ethnicity=3 if s116==.

*************empowerment*************************
*********arranged marriage***********************
gen arranged=.
replace arranged=0 if s716_1==2 | s716_1==3
replace arranged=1 if arranged!=0

*********husband's controlling attitude**********
rename s794a preventfriends
rename s794b limitcon
rename s794c distrust
rename s794d distrust2

gen husbandcontrol=.
replace husbandcontrol= 1 if preventfriends==1 | limitcon==1 | distrust==1 | distrust2==1
replace husbandcontrol=0 if husbandcontrol!=1


*************education***************************
rename v133 womeneduc
rename v715 husbandedu

*********employment******************************
rename v714 emp
gen employed=0
replace employed=emp if emp==1

/*2.B household characteristics*/

************urban/rural**************************
rename v102 urban

**********at least one son***********************
egen son=rowtotal(b4_01-b4_20)
gen atleastone=0
replace atleastone=1 if son!=0

***********number of children under age of 5*****
rename V137 child5

***********wealth********************************
rename v190 wealth

rename v024 region

/* MODEL*///////////////////////////////////////////////////
logistic modern urban age agesq, vce(robust)
outreg2 using dhs2013.doc, replace ctitle(Odds Ratio) eform
logistic modern age agesq urban i.ethnicity, vce(robust)
outreg2 using dhs2013.doc, append ctitle(Odds Ratio) eform
logistic modern age agesq urban i.ethnicity child5 atleastone, vce(robust)
outreg2 using dhs2013.doc, append ctitle(Odds Ratio) eform
logistic modern age agesq urban i.ethnicity child5 atleastone womeneduc husbandedu
outreg2 using dhs2013.doc, append ctitle(Odds Ratio) eform
logistic modern age agesq urban i.ethnicity child5 atleastone womeneduc husbandedu employed wealth i.region, vce(robust)
outreg2 using dhs2013.doc, append ctitle(Odds Ratio) eform

logistic birthcontrol age agesq urban i.ethnicity child5 atleastone womeneduc employed wealth i.region, vce(robust)
outreg2 using dhs2013_1.doc, replace ctitle(Model 1)

save "C:\Users\LENOVO\Desktop\sinan\TRIR62DT\dhs_2013.dta"

/*Part 2: 2018 Sample with Forced Displacement-syrian refugees*/
/* DATA CLEANING*///////////////////////////////////////////

clear
import spss using "C:\Users\LENOVO\Desktop\sinan\hh_individual2018_TR\TRIR71.sav"
gen sample=1
append using syriandata
replace sample=2 if sample!=1 /*2 for Syrian subsample, 1 for Turkey*/
drop age /*previous naming*/

rename V012 age
drop if V213==1 /* exclude pregnant women*/
drop if V501!= 1 /* restrict to married women */
gen agesq= age*age

/*dependent variable*/
gen modern= 0
replace modern=1 if V364== 1

/*independent variables*/
/*2.A. individual observed characteristics*/
*************ethnicity***************************
gen ethnicity=. /*ethnicity: 0= Turkish, 1=Kurdish, 2=Arabic, 3=Other */
replace ethnicity=0 if S114==1
replace ethnicity=1 if S114==2
replace ethnicity=2 if S114==3
replace ethnicity=3 if ethnicity==.

*************empowerment*************************
*********arranged marriage***********************
gen arranged=.
replace arranged=0 if _v4029==2 | _v4029==3
replace arranged=1 if arranged!=0

*********education*******************************
rename V715 husbandedu
rename V133 womenedu

*********employment******************************
rename V714 emp

*********husband's controlling attitude**********
rename S727A preventfriends
rename S727B limitcon
rename S727C distrust
rename S727D distrust2

gen husbandcontrol=.
replace husbandcontrol= 1 if preventfriends==1 | limitcon==1 | distrust==1 | distrust2==1
replace husbandcontrol=0 if husbandcontrol!=1

/*2.B household characteristics*/

************urban/rural**************************
gen urban=.
replace urban=1 if V025==1
replace urban=0 if urban!=1


***********number of children under age of 5*****
rename V137 child5

**********at least one son***********************

egen son=rowtotal(_v121-_v140)
gen atleastone=0
replace atleastone=1 if son!=0

/*MODEL(s)*/
logistic modern age urban, vce(robust)
logistic modern age urban i.ethnicity, vce(robust)
logistic modern age urban i.ethnicity child5, vce(robust)
logistic modern age agesq urban i.ethnicity child5 atleastone, vce(robust)
outreg2 using dhs2018.doc, replace ctitle(Odds Ratio) eform
logistic modern age agesq urban child5 atleastone if sample==2, vce(robust)
outreg2 using dhs2018.doc, append ctitle(Odds Ratio) eform
logistic modern age agesq urban child5 atleastone i.ethnicity womenedu husbandedu emp V190 i.V024 if sample==1, vce(robust)
outreg2 using dhs2018_1.doc, replace ctitle(Odds Ratio) eform
logistic modern age agesq urban child5 atleastone womenedu husbandedu emp if sample==2, vce(robust)
outreg2 using dhs2018.doc, append ctitle(Odds Ratio) eform


/*RESULTS-OUTPUT*///////////////////////
outreg2 using project.doc, replace ctitle(Model 6)