/* prepare-mros-for-nsrr.sas */

*set options and libnames;
libname mros "\\rfawin\bwh-sleepepi-mros\nsrr-prep\_source";
libname obf "\\rfawin\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.3.0.pre;

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
  drop SITE; /* identifier */
run;

data mros2;
  length nsrrid $6. visit 8.;
  merge mrosbase mros.vs2;
  by nsrrid;

  visit = 2;
  gender = 2;
run;

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
