*create mros dataset for NSRR;
libname mros "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_source";
libname obf "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.2.0.beta1;

*import dataset sent by MrOS Coordinating Center;
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
	outfile="\\rfa01\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros1-dataset-&version..csv"
	dbms = csv
	replace;
run;

proc export
	data = mros2
	outfile="\\rfa01\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros2-dataset-&version..csv"
	dbms = csv
	replace;
run;
