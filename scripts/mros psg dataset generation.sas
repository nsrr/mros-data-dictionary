libname mros "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_source\from_mros_cc\datasets";
libname obf "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.1.0;

*import dataset sent by MrOS Coordinating Center;
data mros1;
  length nsrrid $6. visit 8.;
  set mros.vs1;

  visit = 1;
  gender = 2;

run;

data mros2;
  length nsrrid $6. visit 8.;
  set mros.vs2;

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
