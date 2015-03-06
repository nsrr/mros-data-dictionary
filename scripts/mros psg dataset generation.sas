libname mros "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_source";
libname obf "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.1.0.beta2;

*import dataset sent by MrOS Coordinating Center;
data mros1_psg;
  length pdrid visit 8.;
  set mros.Mros1psg_20121019;

  visit = 1;
  gender = 2;

  if envrmtou = -1 then envrmtou = 1;

  *drop unncessary / identifying variables;
  drop cdlabel comm count f2r maltoth maltothdesc;
run;

data mros2_psg;
  length pdrid visit 8.;
  set mros.Mros2psg_20121005;

  visit = 2;
  gender = 2;
  if status ne 1 then delete;

  *drop unncessary / identifying variables;
  drop scorid cdlabel count;
run;

*export dataset;
proc export
	data = mros1_psg
	outfile="\\rfa01\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros1-psg-dataset-&version..csv"
	dbms = csv
	replace;
run;

proc export
	data = mros2_psg
	outfile="\\rfa01\bwh-sleepepi-mros\nsrr-prep\_releases\&version.\mros2-psg-dataset-&version..csv"
	dbms = csv
	replace;
run;
