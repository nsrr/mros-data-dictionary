libname mros "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_source";
libname obf "\\rfa01\bwh-sleepepi-mros\nsrr-prep\_ids";
options nofmterr fmtsearch=(mros);

*set version macro variable;
%let version = 0.1.0.beta1;

*import dataset sent by MrOS Coordinating Center;
data mros1_psg;
  length pdrid visit 8.;
  set mros.Mros1psg_20121019;

  visit = 1;
  gender = 2;

  *drop unncessary / identifying variables;
  *drop scorerid stdatep scoredt StdyDt ScorDt ScorID CDLabel Comm EnterDt dateadd datechange notes nobrslp nobrap nobrc nobro nobrh notca notco notch minmaxhrou pdb5slp prdb5slp nordb2 nordb3 nordb4slp nordb4 nordb5slp nordb5 nordball maxdbslp avgdbslp chinrdur quchinr notcc;
run;

data mros2_psg;
  length pdrid visit 8.;
  set mros.Mros2psg_20121005;

  visit = 2;
  gender = 2;

  *drop unncessary / identifying variables;
  *drop scorerid stdatep scoredt StdyDt ScorDt ScorID CDLabel Comm EnterDt dateadd datechange notes nobrslp nobrap nobrc nobro nobrh notca notco notch minmaxhrou pdb5slp prdb5slp nordb2 nordb3 nordb4slp nordb4 nordb5slp nordb5 nordball maxdbslp avgdbslp chinrdur quchinr notcc;
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
