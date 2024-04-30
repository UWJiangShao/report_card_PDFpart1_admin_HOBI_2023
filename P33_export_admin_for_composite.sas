OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MLOGIC MPRINT SYMBOLGEN noxwait noxsync;

LIBNAME IN02 "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\5. Composite\Data\raw_data\admin";

%LET JOB = P32;

proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\raw_Data\plancode.xlsx"
	dbms=XLSX
	out=plancode
	;
run;


*** ------ STAR Child prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\temp_Data\STAR_Child_for_analysis.xlsx"
	dbms=XLSX
	out=STAR_Child
	;
	sheet="SC23_admin";
run;

/* create round and unround data. Note that for composite calculation, unrounded data is used */ 
data STAR_Child;
	set STAR_Child;
	plancode = compress(plancode, "()");

	W30comp_rat_unround = mean(W3015_rat, W3030_rat);
	WCVcomp_rat_unround = mean(WCV11_rat,WCV17_rat);
	vacc_rat_unround = mean(CIS_rat, IMA_rat);
	
	W30comp_rat = round(mean(W3015_rat, W3030_rat), 0.5);
	WCVcomp_rat = round(mean(WCV11_rat,WCV17_rat), 0.5);
	vacc_rat = round(mean(CIS_rat, IMA_rat), 0.5);

run;



*** ------ STAR Adult prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STAR_Adult_for_analysis.xlsx"
	dbms=XLSX
	out=STAR_Adult
	;
	sheet="SA23_admin";
run;

data STAR_Adult;
	set STAR_Adult;
	plancode = compress(plancode, "()");

	BHcomp_rat_unround = mean(AMM_rat, FUH_rat);
	CDCcomp_rat_unround = mean(KED_rat, EED_rat);

	BHcomp_rat = round(mean(AMM_rat, FUH_rat), 0.5);
	CDCcomp_rat = round(mean(KED_rat, EED_rat), 0.5);

run;


*** ------ STAR + PLUS prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STARPLUS_for_analysis.xlsx"
	dbms=XLSX
	out=STAR_PLUS
	;
	sheet="SP23_admin";
run;


data STAR_PLUS;
	set STAR_PLUS;
	plancode = compress(plancode, "()");

	cancer_rat_unround = mean(BCS_rat, CCS_rat);
	BHcomp_rat_unround = mean(AMM_rat, FUH_rat);
	COPD_rat_unround = mean(mean(PCEcort_rat, PCEbronch_rat), SPR_rat);
	CDCcomp_rat_unround = mean(KED_rat, EED_rat);

	cancer_rat = round(mean(BCS_rat, CCS_rat), 0.5);
	BHcomp_rat = round(mean(AMM_rat, FUH_rat), 0.5);
	COPD_rat = round(mean(mean(PCEcort_rat, PCEbronch_rat), SPR_rat), 0.5);
	CDCcomp_rat = round(mean(KED_rat, EED_rat), 0.5);

run;


*** ------ STAR Kids prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STARKids_for_analysis.xlsx"
	dbms=XLSX
	out=STAR_Kids
	;
	sheet="SK23_admin";
run;

data STAR_Kids;
	set STAR_Kids;
	plancode = compress(plancode, "()");

	WCVcomp_rat_unround = mean(WCV11_rat,WCV17_rat);
	WCVcomp_rat = round(mean(WCV11_rat,WCV17_rat), 0.5);

run;


proc contents data=STAR_Kids varnum;
run;

/* Prepare for merged dataset */ 
data IN02.SC_admin; 
	set STAR_Child;
	keep plancode W3015_rat--vacc_rat;
run;

data IN02.SA_admin;
	set STAR_Adult;
	keep plancode PPCpre_rat--CDCcomp_rat;
run;

data IN02.SP_admin;
	set STAR_Plus;
	keep plancode AAP_rat--CDCcomp_rat;
run;

/* SK: Note that for APM, one is for survey, one is for admin*/
data IN02.SK_admin;
	set STAR_Kids;
	rename APM_rat = APM_admin_rat;
	keep plancode WCV11_rat--WCVcomp_rat;
run;

