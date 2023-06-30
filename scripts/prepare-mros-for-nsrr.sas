/* prepare-mros-for-nsrr.sas */

*set options and libnames;
libname mros "\\rfawin\bwh-sleepepi-mros\nsrr-prep\_source";
libname obf "\\rfawin\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.7.0.pre;

*process datasets sent by mros coordinating center;
data mrosbase;
  length nsrrid $6.;
  set mros.base;
run;

data mros1;
  length nsrrid $6. visit 8.;
  merge 
    mrosbase 
    mros.vs1 
    mros.posaug20
    ;
  by nsrrid;

  visit = 1;
  gender = 2;

  *recode ages 90 or above to 90;
  if vsage1 > 89 then vsage1 = 90;

  *create lights-on time;
  format postlont time8.;
  postlont = postlotp + (potimebd * 60);
  if postlont >= 86400 then postlont = postlont - 86400;

  *create decimal hours variables for PSG lights/onset;
  format postlotp_dec postontp_dec postlont_dec 8.2;
  if postlotp < 43200 then postlotp_dec = postlotp/3600 + 24;
  else postlotp_dec = postlotp/3600;
  if postontp < 43200 then postontp_dec = postontp/3600 + 24;
  else postontp_dec = postontp/3600;
  if postlont < 43200 then postlont_dec = postlont/3600 + 24;
  else postlont_dec = postlont/3600;

  *drop variables;
  drop 
    poremli /*redundant variable (keep poremlat)*/
    postdydt /* identifier */
    ;
run;

/*

data mros1test;
  set mros1;

  time_diff = postlont_dec - postlotp_dec;
run;

proc freq data=mros1test;
  table postlotp_dec postontp_dec postlont_dec time_diff;
run;

proc sql;
  select nsrrid, postlotp, postontp, postlont, postlotp_dec, postontp_dec, postlont_dec, time_diff
  from mros1test
  where time_diff > 15;
quit;

*/

data mros1_hrv;
  length nsrrid $6. visit 8.;
  merge 
    mrosbase 
    mros.hvsfeb15_deid (in=a)
    ;
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
  merge 
    mrosbase 
    mros.vs2
    mros.pos2aug20
    ;
  by nsrrid;

  visit = 2;
  gender = 2;

  *recode ages 90 or above to 90;
  if vs2age1 > 89 then vs2age1 = 90;

  *create lights-on time;
  format postlont time8.;
  postlont = postlotp + (potimebd * 60);
  if postlont >= 86400 then postlont = postlont - 86400;

  *create decimal hours variables for PSG lights/onset;
  format postlotp_dec postontp_dec postlont_dec 8.2;
  if postlotp < 43200 then postlotp_dec = postlotp/3600 + 24;
  else postlotp_dec = postlotp/3600;
  if postontp < 43200 then postontp_dec = postontp/3600 + 24;
  else postontp_dec = postontp/3600;
  if postlont < 43200 then postlont_dec = postlont/3600 + 24;
  else postlont_dec = postlont/3600;

  *drop variables;
  drop 
    poremli /*redundant variable (keep poremlat)*/
    remlaip /*redundant variable (keep poremlat)*/
    postdydt /* identifier */
    ;
run;

/*

data mros2test;
  set mros2;

  time_diff = postlont_dec - postlotp_dec;
run;

proc freq data=mros2test;
  table postlotp_dec postontp_dec postlont_dec time_diff;
run;

proc sql;
  select nsrrid, postlotp, postontp, postlont, postlotp_dec, postontp_dec, postlont_dec, time_diff
  from mros2test
  where time_diff > 15;
quit;

proc freq data=mros2test;
  table poslpmef;
run;

proc means data=mros2test;
  var potimebd poslpeff ;
run;

*/


*******************************************************************************;
* create harmonized datasets ;
*******************************************************************************;
* create harmonized data for visit 1;
data mros1_harmonized;
  set mros1;

*demographics 
*age;
*use vsage1;
  format nsrr_age 8.2;
  if vsage1 gt 89 then nsrr_age = 90;
  else if vsage1 le 89 then nsrr_age = vsage1;

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

*polysomnography;
*nsrr_ahi_hp3u;
*use poahi3;
  format nsrr_ahi_hp3u 8.2;
  nsrr_ahi_hp3u = poahi3;

*nsrr_ahi_hp3r_aasm15;
*use poahi3a;
  format nsrr_ahi_hp3r_aasm15 8.2;
  nsrr_ahi_hp3r_aasm15 = poahi3a;
 
*nsrr_ahi_hp4u_aasm15;
*use poahi4;
  format nsrr_ahi_hp4u_aasm15 8.2;
  nsrr_ahi_hp4u_aasm15 = poahi4;
  
*nsrr_ahi_hp4r;
*use poahi4a;
  format nsrr_ahi_hp4r 8.2;
  nsrr_ahi_hp4r = poahi4a;
 
*nsrr_ttldursp_f1;
*use poslprdp;
  format nsrr_ttldursp_f1 8.2;
  nsrr_ttldursp_f1 = poslprdp;
  
*nsrr_phrnumar_f1;
*use poai_all;
  format nsrr_phrnumar_f1 8.2;
  nsrr_phrnumar_f1 = poai_all;  

*nsrr_flag_spsw;
*use poprstag;
  format nsrr_flag_spsw $100.;
    if poprstag = 1 then nsrr_flag_spsw = 'sleep/wake only';
    else if poprstag = 0 then nsrr_flag_spsw = 'full scoring';
    else if poprstag = 8 then nsrr_flag_spsw = 'unknown';
  else if poprstag = . then nsrr_flag_spsw = 'unknown';  
  
*nsrr_ttleffsp_f1;
*use poslpeff;
  format nsrr_ttleffsp_f1 8.2;
  nsrr_ttleffsp_f1 = poslpeff;  

*nsrr_ttllatsp_f1;
*use posllatp;
  format nsrr_ttllatsp_f1 8.2;
  nsrr_ttllatsp_f1 = posllatp; 

*nsrr_ttlprdsp_s1sr;
*use poremlat;
  format nsrr_ttlprdsp_s1sr 8.2;
  nsrr_ttlprdsp_s1sr = poremlat; 

*nsrr_ttldursp_s1sr;
*use poremlii;
  format nsrr_ttldursp_s1sr 8.2;
  nsrr_ttldursp_s1sr = poremlii; 

*nsrr_ttldurws_f1;
*use powaso;
  format nsrr_ttldurws_f1 8.2;
  nsrr_ttldurws_f1 = powaso;
  
*nsrr_pctdursp_s1;
*use potmst1p;
  format nsrr_pctdursp_s1 8.2;
  nsrr_pctdursp_s1 = potmst1p;

*nsrr_pctdursp_s2;
*use potmst2p;
  format nsrr_pctdursp_s2 8.2;
  nsrr_pctdursp_s2 = potmst2p;

*nsrr_pctdursp_s3;
*use potms34p;
  format nsrr_pctdursp_s3 8.2;
  nsrr_pctdursp_s3 = potms34p;

*nsrr_pctdursp_sr;
*use potmremp;
  format nsrr_pctdursp_sr 8.2;
  nsrr_pctdursp_sr = potmremp;

*nsrr_ttlprdbd_f1;
*use potimebd;
  format nsrr_ttlprdbd_f1 8.2;
  nsrr_ttlprdbd_f1 = potimebd;  
  
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
  nsrr_ahi_hp3u
  nsrr_ahi_hp3r_aasm15
  nsrr_ahi_hp4u_aasm15
  nsrr_ahi_hp4r
  nsrr_ttldursp_f1
  nsrr_phrnumar_f1
  nsrr_flag_spsw
  nsrr_ttleffsp_f1
  nsrr_ttllatsp_f1
  nsrr_ttlprdsp_s1sr
  nsrr_ttldursp_s1sr
  nsrr_ttldurws_f1
  nsrr_pctdursp_s1
  nsrr_pctdursp_s2
  nsrr_pctdursp_s3
  nsrr_pctdursp_sr
  nsrr_ttlprdbd_f1
    ;
run;

* create harmonized data for visit 2;
data mros2_harmonized;
  set mros2;

*demographics 
*age;
*use vs2age1;
  format nsrr_age 8.2;
  if vs2age1 gt 89 then nsrr_age = 90;
  else if vs2age1 le 89 then nsrr_age = vs2age1;

*age_gt89;
*use vs2age1;
  format nsrr_age_gt89 $100.; 
  if vs2age1 gt 89 then nsrr_age_gt89='yes';
  else if vs2age1 le 89 then nsrr_age_gt89='no';

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
*use tursmok2;
  format nsrr_current_smoker $100.;
    if tursmok2 = '2' then nsrr_current_smoker = 'yes';
    else if tursmok2 = '0' then nsrr_current_smoker = 'no';
    else if tursmok2 = '1'  then nsrr_current_smoker = 'no';
    else if tursmok2 = 'A'  then nsrr_current_smoker = 'not reported';
  else nsrr_current_smoker = 'not reported';

*ever_smoker;
*use tursmok2;
  format nsrr_ever_smoker $100.;
    if tursmok2 = '1' then nsrr_ever_smoker = 'yes';
    else if tursmok2 = '2' then nsrr_ever_smoker = 'yes';
    else if tursmok2 = '0'  then nsrr_ever_smoker = 'no';
    else if tursmok2 = 'A'  then nsrr_ever_smoker = 'not reported';
  else nsrr_ever_smoker = 'not reported';

*polysomnography;
*nsrr_ahi_hp3u;
*use poahi3;
  format nsrr_ahi_hp3u 8.2;
  nsrr_ahi_hp3u = poahi3;

*nsrr_ahi_hp3r_aasm15;
*use poahi3a;
  format nsrr_ahi_hp3r_aasm15 8.2;
  nsrr_ahi_hp3r_aasm15 = poahi3a;
 
*nsrr_ahi_hp4u_aasm15;
*use poahi4;
  format nsrr_ahi_hp4u_aasm15 8.2;
  nsrr_ahi_hp4u_aasm15 = poahi4;
  
*nsrr_ahi_hp4r;
*use poahi4a;
  format nsrr_ahi_hp4r 8.2;
  nsrr_ahi_hp4r = poahi4a;
 
*nsrr_ttldursp_f1;
*use poslprdp;
  format nsrr_ttldursp_f1 8.2;
  nsrr_ttldursp_f1 = poslprdp;
  
*nsrr_phrnumar_f1;
*use poai_all;
  format nsrr_phrnumar_f1 8.2;
  nsrr_phrnumar_f1 = poai_all;  

*nsrr_flag_spsw;
*use poprstag;
  format nsrr_flag_spsw $100.;
    if poprstag = 1 then nsrr_flag_spsw = 'sleep/wake only';
    else if poprstag = 0 then nsrr_flag_spsw = 'full scoring';
    else if poprstag = 8 then nsrr_flag_spsw = 'unknown';
  else if poprstag = . then nsrr_flag_spsw = 'unknown';  
  
*nsrr_ttleffsp_f1;
*use poslpeff;
  format nsrr_ttleffsp_f1 8.2;
  nsrr_ttleffsp_f1 = poslpeff;  

*nsrr_ttllatsp_f1;
*use posllatp;
  format nsrr_ttllatsp_f1 8.2;
  nsrr_ttllatsp_f1 = posllatp; 

*nsrr_ttlprdsp_s1sr;
*use poremlat;
  format nsrr_ttlprdsp_s1sr 8.2;
  nsrr_ttlprdsp_s1sr = poremlat; 

*nsrr_ttldursp_s1sr;
*use poremlii;
  format nsrr_ttldursp_s1sr 8.2;
  nsrr_ttldursp_s1sr = poremlii; 

*nsrr_ttldurws_f1;
*use powaso;
  format nsrr_ttldurws_f1 8.2;
  nsrr_ttldurws_f1 = powaso;
  
*nsrr_pctdursp_s1;
*use potmst1p;
  format nsrr_pctdursp_s1 8.2;
  nsrr_pctdursp_s1 = potmst1p;

*nsrr_pctdursp_s2;
*use potmst2p;
  format nsrr_pctdursp_s2 8.2;
  nsrr_pctdursp_s2 = potmst2p;

*nsrr_pctdursp_s3;
*use potms34p;
  format nsrr_pctdursp_s3 8.2;
  nsrr_pctdursp_s3 = potms34p;

*nsrr_pctdursp_sr;
*use potmremp;
  format nsrr_pctdursp_sr 8.2;
  nsrr_pctdursp_sr = potmremp;

*nsrr_ttlprdbd_f1;
*use potimebd;
  format nsrr_ttlprdbd_f1 8.2;
  nsrr_ttlprdbd_f1 = potimebd;  
  
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
  nsrr_ahi_hp3u
  nsrr_ahi_hp3r_aasm15
  nsrr_ahi_hp4u_aasm15
  nsrr_ahi_hp4r
  nsrr_ttldursp_f1
  nsrr_phrnumar_f1
  nsrr_flag_spsw
  nsrr_ttleffsp_f1
  nsrr_ttllatsp_f1
  nsrr_ttlprdsp_s1sr
  nsrr_ttldursp_s1sr
  nsrr_ttldurws_f1
  nsrr_pctdursp_s1
  nsrr_pctdursp_s2
  nsrr_pctdursp_s3
  nsrr_pctdursp_sr
  nsrr_ttlprdbd_f1
    ;
run;

* concatenate mros1, and mros2 harmonized datasets;
data mros_harmonized;
   set mros1_harmonized mros2_harmonized;
run;

proc sort data=mros_harmonized;
  by nsrrid visit;
run;

*******************************************************************************;
* checking harmonized datasets ;
*******************************************************************************;

/* Checking for extreme values for continuous variables */

proc means data=mros_harmonized;
VAR   nsrr_age
    nsrr_bmi
  nsrr_bp_systolic
    nsrr_bp_diastolic
  nsrr_ahi_hp3u
  nsrr_ahi_hp3r_aasm15
  nsrr_ahi_hp4u_aasm15
  nsrr_ahi_hp4r
  nsrr_ttldursp_f1
  nsrr_phrnumar_f1
  nsrr_ttleffsp_f1
  nsrr_ttllatsp_f1
  nsrr_ttlprdsp_s1sr
  nsrr_ttldursp_s1sr
  nsrr_ttldurws_f1
  nsrr_pctdursp_s1
  nsrr_pctdursp_s2
  nsrr_pctdursp_s3
  nsrr_pctdursp_sr
  nsrr_ttlprdbd_f1;
run;

/* Checking categorical variables */

proc freq data=mros_harmonized;
table   nsrr_age_gt89
    nsrr_sex
    nsrr_race
    nsrr_ethnicity
    nsrr_current_smoker
    nsrr_ever_smoker
  nsrr_flag_spsw;
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
%lowcase(mros_harmonized);

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
  data = mros_harmonized
  outfile="\\rfawin\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros-harmonized-dataset-&version..csv"
  dbms = csv
  replace;
run;
