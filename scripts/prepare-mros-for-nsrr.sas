/* prepare-mros-for-nsrr.sas */

*set options and libnames;
libname mros "\\rfawin\bwh-sleepepi-mros\nsrr-prep\_source";
libname obf "\\rfawin\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.6.0.pre;

*process datasets sent by mros coordinating center;
data mrosbase;
  length nsrrid $6.;
  set mros.base;
run;

data mros1;
  length nsrrid $6. visit 8.;
  merge mrosbase mros.vs1;
  by nsrrid;

  visit = 1;
  gender = 2;

  *recode ages 90 or above to 90;
  if vsage1 > 89 then vsage1 = 90;

  *drop variables;
  drop 
    postdydt /* identifier */
    ;
run;

data mros1_hrv;
  length nsrrid $6. visit 8.;
  merge mrosbase mros.hvsfeb15_deid (in=a);
  by nsrrid;

  *only keep those in hvs dataset;
  if a;

  visit = 1;
  gender = 2;

  *remove extraneous sas formats;
  format HVNUMEPOCH--HVDFALPHA2;

  *remove variables;
  drop 
    SITE; /* identifier */
run;

data mros2;
  length nsrrid $6. visit 8.;
  merge mrosbase mros.vs2;
  by nsrrid;

  visit = 2;
  gender = 2;

  *recode ages 90 or above to 90;
  if vs2age1 > 89 then vs2age1 = 90;

  *drop variables;
  drop 
    postdydt /* identifier */
    ;
run;

*******************************************************************************;
* create harmonized datasets ;
*******************************************************************************;
data mros1_harmonized;
	set mros1;

*demographics
*age;
*use vsage1;
	format nsrr_age 8.2;
 	nsrr_age = vsage1;

*age_gt89;
*use vsage1;
	format nsrr_age_gt89 $100.; 
	if vsage1 gt 89 then nsrr_age_gt89='yes';
	else if vsage1 le 89 then nsrr_age_gt89='no';

*sex;
*use gender;
	format nsrr_sex $100.;
	if gender = '02' then nsrr_sex = 'male';
	else if gender = '01' then nsrr_sex = 'female';
	else if gender = '.' then nsrr_sex = 'not reported';

*race;
*use gierace;
    format nsrr_race $100.;
    if gierace = 1 then nsrr_race = 'white';
    else if gierace = 2 then nsrr_race = 'black or african american';
    else if gierace = 3 then nsrr_race = 'asian';
  	else if gierace = 4 then nsrr_race = 'hispanic';
	else if gierace = 5 then nsrr_race = 'other';
	else  nsrr_race = 'not reported';

*ethnicity;
*use gierace;
	format nsrr_ethnicity $100.;
    if gierace = 4 then nsrr_ethnicity = 'hispanic or latino';
    else if gierace = 1 then nsrr_ethnicity = 'not hispanic or latino';
	else if gierace = 2  then nsrr_ethnicity = 'not hispanic or latino';
	else if gierace = 3   then nsrr_ethnicity = 'not hispanic or latino';
	else if gierace = 5  then nsrr_ethnicity = 'not hispanic or latino';
	else if gierace = '.' then nsrr_ethnicity = 'not reported';

*anthropometry
*bmi;
*use hwbmi;
	format nsrr_bmi 10.9;
 	nsrr_bmi = hwbmi;

*clinical data/vital signs
*bp_systolic;
*use bpbpsysm;
	format nsrr_bp_systolic 8.2;
	nsrr_bp_systolic = bpbpsysm;

*bp_diastolic;
*use bpbpdiam;
	format nsrr_bp_diastolic 8.2;
 	nsrr_bp_diastolic = bpbpdiam;

*lifestyle and behavioral health
*current_smoker;
*use tusmknow;
	format nsrr_current_smoker $100.;
    if tusmknow = '1' then nsrr_current_smoker = 'yes';
    else if tusmknow = '0' then nsrr_current_smoker = 'no';
    else if tusmknow = 'A'  then nsrr_current_smoker = 'not reported';
    else if tusmknow = 'D'  then nsrr_current_smoker = 'not reported';
	else if tusmknow = 'K'  then nsrr_current_smoker = 'not reported';
	else if tusmknow = 'M'  then nsrr_current_smoker = 'not reported';

*ever_smoker;
*use tursmoke;
	format nsrr_ever_smoker $100.;
    if tursmoke = '1' then nsrr_ever_smoker = 'yes';
    else if tursmoke = '2' then nsrr_ever_smoker = 'yes';
    else if tursmoke = '0'  then nsrr_ever_smoker = 'no';
    else if tursmoke = 'A'  then nsrr_ever_smoker = 'not reported';
	else nsrr_ever_smoker = 'not reported';

	keep 
		nsrrid
		visit
		nsrr_age
		nsrr_age_gt89
		nsrr_sex
		nsrr_race
		nsrr_ethnicity
		nsrr_bmi
		nsrr_bp_systolic
		nsrr_bp_diastolic
		nsrr_current_smoker
		nsrr_ever_smoker
		;
run;

*******************************************************************************;
* checking harmonized datasets ;
*******************************************************************************;

/* Checking for extreme values for continuous variables */

proc means data=mros1_harmonized;
VAR 	nsrr_age
		nsrr_bmi
		nsrr_bp_systolic
		nsrr_bp_diastolic;
run;

/* Checking categorical variables */

proc freq data=mros1_harmonized;
table 	nsrr_age_gt89
		nsrr_sex
		nsrr_race
		nsrr_ethnicity
		nsrr_current_smoker
		nsrr_ever_smoker;
run;

*******************************************************************************;
* make all variable names lowercase ;
*******************************************************************************;
*(macro source: maryland population research center);
options mprint;
%macro lowcase(dsn);
     %let dsid=%sysfunc(open(&dsn));
     %let num=%sysfunc(attrn(&dsid,nvars));
     %put &num;
     data &dsn;
           set &dsn(rename=(
        %do i = 1 %to &num;
        %let var&i=%sysfunc(varname(&dsid,&i));    /*function of varname returns the name of a SAS data set variable*/
        &&var&i=%sysfunc(lowcase(&&var&i))         /*rename all variables*/
        %end;));
        %let close=%sysfunc(close(&dsid));
  run;
%mend lowcase;

%lowcase(mros1);
%lowcase(mros1_hrv);
%lowcase(mros2);
%lowcase(mros1_harmonized);

*export dataset;
proc export
  data = mros1
  outfile="\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros-visit1-dataset-&version..csv"
  dbms = csv
  replace;
run;

proc export
  data = mros1_hrv
  outfile="\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\hrv-analysis\mros-visit1-hrv-summary-&version..csv"
  dbms = csv
  replace;
run;

proc export
  data = mros2
  outfile="\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros-visit2-dataset-&version..csv"
  dbms = csv
  replace;
run;

proc export
  data = mros1_harmonized
  outfile="\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros-visit1-harmonized-&version..csv"
  dbms = csv
  replace;
run;
