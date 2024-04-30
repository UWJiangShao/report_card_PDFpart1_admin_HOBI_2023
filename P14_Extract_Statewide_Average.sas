OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MLOGIC MPRINT SYMBOLGEN;

* Extract statewide average measure rate from Annual QOC report;

%LET JOB = P14;

LIBNAME QOC22 "..\Data\Raw_Data";
LIBNAME OUT "..\Data\Temp_Data";

* For each measure in the list, extract statewide level average rate;
* create macro to extract info for each measure;
%macro extract(program, measurename, submeasurename, outname);
	data &program._&outname.;
		set &program.;
		where MEASURENAME =: &measurename.
			and prxmatch(&submeasurename., SUBMEASURENAME)
			and POPULATIONNAME = "ALL"
			;
		length outname $10;
		outname = "&outname.";
	run;
%mend extract;



* STAR;
DATA STAR;
	SET QOC22.STAR_HEDIS_ALL;
	* rate2 = .;
	* if denom ne 0 then rate2 = numer / denom;
RUN;

* For STAR Adult;
%extract(STAR, "Pren Post Care MY22 (PPCMY22)", "/Timeliness of prenatal care/", PPCpre);
%extract(STAR, "Pren Post Care MY22 (PPCMY22)", "/Postpartum care/", PPCpost);
%extract(STAR, "Adults Access MY22 (AAPMY22)", "/All members/", AAP);
%extract(STAR, "Cervical Cancer MY22 (CCSMY22)", "//" , CCS);
%extract(STAR, "Antidepress Rx MY22 (AMMMY22)", "/Effective Acute Phase Treatment/", AMM);
%extract(STAR, "F/U Hosp for MH MY22 (FUHMY22)", "/Total Follow Up within 7 Days/", FUH);
%extract(STAR, "Kidney Hth Diab MY22 (KEDMY22)", "/Non-MCR Members Total\s*$/", KED);

/* %extract(STAR, "HbA1c C Non-MCR MY22 (HBDMY22B)", "/Non-Medicare HbA1c Control \(<8\)/", HBaTest8);
%extract(STAR, "HbA1c C Non-MCR MY22 (HBDMY22B)", "/Non-Medicare HbA1c Control \(>9\)/", HBaTest9); */

%extract(STAR, "Eye Exam N MCR MY22 (EEDMY22B)", "/Non-Medicare Eye Exam/", EED);

data STAR_Adult_statewide_average;
	set 
		STAR_PPCpre
		STAR_PPCpost
		STAR_AAP
		STAR_CCS
		STAR_AMM
		STAR_FUH
		STAR_KED

		/* STAR_CDCtest
		STAR_CDCeye */

		STAR_EED
		;
	LENGTH program $ 12;
	program = "STAR_Adult";
	keep program outname numer denom rate;
run;




* For STAR Child;
%extract(STAR, "Well Child 30 MY22 (W30MY22)", "/Well child visits in the first 15 months/", W3015);
%extract(STAR, "Well Child 30 MY22 (W30MY22)", "/Well child visits for age15-30 months/", W3030);
%extract(STAR, "Well Care Vst MY22 (WCVMY22)", "/3 to 11 years old/", WCV11);
%extract(STAR, "Well Care Vst MY22 (WCVMY22)", "/12 to 17 years old/", WCV17);
%extract(STAR, "Childhood Imm MY22 (CISMY22)", "/Combination 10 Immunizations/", CIS);
%extract(STAR, "Imms Adolescent MY22 (IMAMY22)", "/Combination 2 Immunizations/", IMA);
%extract(STAR, "Asthma Rx Ratio MY22 (AMRMY22)", "/Age 5 to 11 Ratio > 0.50/", AMR511);
%extract(STAR, "Asthma Rx Ratio MY22 (AMRMY22)", "/Age 12 to 18 Ratio > 0.50/", AMR1218);

	* Combine AMR from age 5 to 11 and age 12 to 18;
	proc sql;
		create table STAR_AMR as 
		select "AMR" as outname
				,A.numer + B.numer as numer
				,A.Denom + B.Denom as Denom
				,(A.numer + B.numer) / (A.Denom + B.Denom) * 100 as rate format =  8.2
			from STAR_AMR511 A, STAR_AMR1218 B
			;
	quit;

%extract(STAR, "F/U for ADHD Rx MY22 (ADDMY22)", "/Initiation Phase/", ADD);



data STAR_Child_statewide_average;
	set 
		STAR_W3015 
		STAR_W3030
		STAR_WCV11
		STAR_WCV17
		STAR_CIS
		STAR_IMA
		STAR_AMR 
		STAR_ADD
		;
	format rate 8.2;
	LENGTH program $ 12;
	program = "STAR_Child";
	keep program outname numer denom rate;
run;


* STAR+PLUS;
DATA STARPLUS;
	SET QOC22.STARPLUS_HEDIS_ALL;
	* rate2 = .;
	* if denom ne 0 then rate2 = numer / denom;
RUN;

%extract(STARPLUS, "Adults Access MY22 (AAPMY22)", "/All members/", AAP);
%extract(STARPLUS, "Breast Cancer MY22 (BCSMY22)", "/Non-Medicare Total\s*$/", BCS);
%extract(STARPLUS, "Cervical Cancer MY22 (CCSMY22)", "//", CCS);
%extract(STARPLUS, "Antidepress Rx MY22 (AMMMY22)", "/Effective Acute Phase Treatment/", AMM);
%extract(STARPLUS, "F/U Hosp for MH MY22 (FUHMY22)", "/Total Follow Up within 7 Days/", FUH);
%extract(STARPLUS, "Init Engage SUD MY22 (IETMY22)", "/Initiation total \(18-64\)/", IET); 
%extract(STARPLUS, "Pharm Mgmt COPD MY22 (PCEMY22)", "/Bronchodilators/", PCEbronch);
%extract(STARPLUS, "Pharm Mgmt COPD MY22 (PCEMY22)", "/Systemic Corticosteroids/", PCEcort);
%extract(STARPLUS, "Use Spirometry MY22 (SPRMY22)", "/./", SPR);
%extract(STARPLUS, "Kidney Hth Diab MY22 (KEDMY22)", "/Non-MCR Members Total\s*$/", KED);

/* %extract(STARPLUS, "Comp Diab N MCR MY22 (CDCMY22B)", "/Non-Medicare HbA1c Test/", CDCtest); */

%extract(STARPLUS, "Eye Exam N MCR MY22 (EEDMY22B)", "/Non-Medicare Eye Exam/", EED);


DATA STARPLUS_statewide_average;
	set 
		STARPLUS_AAP
		STARPLUS_BCS
		STARPLUS_CCS
		STARPLUS_AMM
		STARPLUS_FUH
		STARPLUS_IET
		STARPLUS_PCEbronch
		STARPLUS_PCEcort
		STARPLUS_SPR
		STARPLUS_KED

		/* STARPLUS_CDCtest
		STARPLUS_CDCeye */

		STARPLUS_EED
		;
	LENGTH program $ 12;
	program = "STARPLUS";
	keep program outname numer denom rate;
run;


* STAR Kids;
DATA STARKIDS;
	SET QOC22.STARKIDS_HEDIS_ALL;
	* rate2 = .;
	* if denom ne 0 then rate2 = numer / denom;
RUN;


%extract(STARKIDS, "Well Care Vst MY22 (WCVMY22)", "/3 to 11 years old/", WCV11);
%extract(STARKIDS, "Well Care Vst MY22 (WCVMY22)", "/12 to 17 years old/", WCV17);
%extract(STARKIDS, "F/U Hosp for MH MY22 (FUHMY22)", "/Total Follow Up within 7 Days/", FUH);
%extract(STARKIDS, "Metabol Antipsy MY22 (APMMY22)", "/Glucose and Chol Combined - All Ages/", APM);

DATA STARKIDS_statewide_average;
	set 
		STARKIDS_WCV11
		STARKIDS_WCV17
		STARKIDS_FUH
		STARKIDS_APM
		;
	LENGTH program $ 12;
	program = "STARKIDS";
	keep program outname numer denom rate;
RUN;


DATA STATEWIDE_AVERAGE;
	RETAIN program outname numer denom rate;
	SET 
/*		CHIP_statewide_average*/
		STAR_Adult_statewide_average
		STAR_Child_statewide_average
		STARPLUS_statewide_average
		STARKIDS_statewide_average
		;
		format rate 8.2;
RUN;

* ods excel file="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STATEWIDE_AVERAGE.xlsx" 
* 	options (sheet_name = "STATEWIDE_AVERAGE");

* PROC PRINT DATA=STATEWIDE_AVERAGE NOOBS;
* 	format rate 8.2;
* RUN;

* ods excel close;

/*proc export data=STATEWIDE_AVERAGE*/
/*	outfile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STATEWIDE_AVERAGE.xlsx"*/
/*	dbms=xlsx*/
/*	replace*/
/*	;*/
/*run;*/

