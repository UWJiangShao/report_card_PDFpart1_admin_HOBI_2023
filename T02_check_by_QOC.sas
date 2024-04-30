OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MLOGIC MPRINT SYMBOLGEN;

* Extract plancode-level measure rate from Annual QOC report;

%LET JOB = P12;

LIBNAME QOC22 "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Raw_Data";
LIBNAME OUT "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data";
LIBNAME QOC21 "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\old\2. Admin\Data\Raw_Data";

proc sql;
	select distinct Measurename
	from QOC22.STAR_HEDIS_ALL;
quit;

* For each measure in the list, create two columns in plancode level: 1:measure rate, 2:denominator
* create macro to extract info for each measure;
/*%macro extract(program, measurename, submeasurename, outname);*/
/*	data &program._&outname.;*/
/*		set &program.;*/
/*		where MEASURENAME =: &measurename.*/
/*			and prxmatch(&submeasurename., SUBMEASURENAME)*/
/*			and POPULATIONNAME in: ("ST_", "SP_", "SK_")*/
/*			;*/
/*		rename rate2 = &outname.*/
/*			denom = &outname._den*/
/*			;*/
/*	run;*/
/**/
/*	proc sort data=&program._&outname.;*/
/*		by plancodes;*/
/*	run;*/
/*%mend extract;*/


%macro extract(program, measurename, submeasurename, outname);
	data &program._&outname.;
		set &program.;
		where MEASURENAME =: &measurename.
			and prxmatch(&submeasurename., SUBMEASURENAME)
			and POPULATIONNAME in: ("STM_")
			;
		rename rate2 = &outname.
			denom = &outname._den
			;
	run;

	proc sort data=&program._&outname. (keep=Measurename submeasurename PopulationName1 Plancodes Numer &outname._den administrative_numerator supplemental_numerator rate);
		by plancodes;
		by PopulationName1;
	run;
%mend extract;

* STAR;
DATA STAR;
	SET QOC22.STAR_HEDIS_ALL;
	rate2 = .;
	if denom ne 0 then rate2 = numer / denom;
RUN;


* For STAR Adult;
%extract(STAR, "Pren Post Care MY22 (PPCMY22)", "/Timeliness of prenatal care/", PPCpre);
%extract(STAR, "Pren Post Care MY22 (PPCMY22)", "/Postpartum care/", PPCpost);
%extract(STAR, "Adults Access MY22 (AAPMY22)", "/All members/", AAP);
%extract(STAR, "Cervical Cancer MY22 (CCSMY22)", "//" , CCS);
%extract(STAR, "Antidepress Rx MY22 (AMMMY22)", "/Effective Acute Phase Treatment/", AMM);
%extract(STAR, "F/U Hosp for MH MY22 (FUHMY22)", "/Total Follow Up within 7 Days/", FUH);
%extract(STAR, "Kidney Hth Diab MY22 (KEDMY22)", "/Non-MCR Members Total\s*$/", KED);

* We proposed to exclude the Hemoglobin test for 2023 Report card;

/* %extract(STAR, "HbA1c C Non-MCR MY22 (HBDMY22B)", "/Non-Medicare HbA1c Control \(<8\)/", HBaTest8);
%extract(STAR, "HbA1c C Non-MCR MY22 (HBDMY22B)", "/Non-Medicare HbA1c Control \(>9\)/", HBaTest9); */

%extract(STAR, "Eye Exam N MCR MY22 (EEDMY22B)", "/Non-Medicare Eye Exam/", EED);


/*data STAR_Adult_for_analysis;*/
/*	merge */
/*		STAR_PPCpre(keep=plancodes PPCpre PPCpre_den)*/
/*		STAR_PPCpost(keep=plancodes PPCpost PPCpost_den)*/
/*		STAR_AAP(keep=plancodes AAP AAP_den)*/
/*		STAR_CCS(keep=plancodes CCS CCS_den)*/
/*		STAR_AMM(keep=plancodes AMM AMM_den)*/
/*		STAR_FUH(keep=plancodes FUH FUH_den)*/
/*		STAR_KED(keep=plancodes KED KED_den)*/
/**/
/*		/* STAR_HbaTest8(keep=plancodes HbaTest8 HbaTest8_den)*/
/*		STAR_HbaTest9(keep=plancodes HbaTest9 HbaTest9_den) */*/
/**/
/*		STAR_EED(keep=plancodes EED EED_den)*/
/*		;*/
/*	by plancodes;*/
/*	rename plancodes = plancode;*/
/*run;*/

/*proc export data=STAR_Adult_for_analysis*/
/*	outfile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STAR_Adult_for_analysis.xlsx"*/
/*	dbms=xlsx*/
/*	replace*/
/*	;*/
/*run;*/

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
		select coalesce(A.plancodes, B.plancodes) as plancodes
				,(A.numer + B.numer) / (A.AMR511_den + B.AMR1218_den) as AMR
				,A.AMR511_den + B.AMR1218_den as AMR_den
			from STAR_AMR511 A
			full join STAR_AMR1218 B on A.plancodes = B.plancodes
			;
	quit;

%extract(STAR, "F/U for ADHD Rx MY22 (ADDMY22)", "/Initiation Phase/", ADD);


data STAR_Child_for_analysis;
	merge 
		STAR_W3015(keep=plancodes W3015 W3015_den)
		STAR_W3030(keep=plancodes W3030 W3030_den)
		STAR_WCV11(keep=plancodes WCV11 WCV11_den)
		STAR_WCV17(keep=plancodes WCV17 WCV17_den)
		STAR_CIS(keep=plancodes CIS CIS_den)
		STAR_IMA(keep=plancodes IMA IMA_den)
		STAR_AMR(keep=plancodes AMR AMR_den)
		STAR_ADD(keep=plancodes ADD ADD_den)
		;
	by plancodes;
	rename plancodes = plancode;
run;

/*proc export data=STAR_Child_for_analysis*/
/*	outfile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STAR_Child_for_analysis.xlsx"*/
/*	dbms=xlsx*/
/*	replace*/
/*	;*/
/*run;*/





* STAR+PLUS;
DATA STARPLUS;
	SET QOC22.STARPLUS_HEDIS_ALL;
	rate2 = .;
	if denom ne 0 then rate2 = numer / denom;
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

DATA STARPLUS_for_analysis;
	MERGE 
		STARPLUS_AAP(KEEP=plancodes AAP AAP_den)
		STARPLUS_BCS(KEEP=plancodes BCS BCS_den)
		STARPLUS_CCS(KEEP=plancodes CCS CCS_den)
		STARPLUS_AMM(KEEP=plancodes AMM AMM_den)
		STARPLUS_FUH(KEEP=plancodes FUH FUH_den)
		STARPLUS_IET(KEEP=plancodes IET IET_den)
		STARPLUS_PCEbronch(KEEP=plancodes PCEbronch PCEbronch_den)
		STARPLUS_PCEcort(KEEP=plancodes PCEcort PCEcort_den)
		STARPLUS_SPR(KEEP=plancodes SPR SPR_den)
		STARPLUS_KED(KEEP=plancodes KED KED_den)

		/* STARPLUS_CDCtest(KEEP=plancodes CDCtest CDCtest_den) */
		
		STARPLUS_EED(KEEP=plancodes EED EED_den)
		;
	BY plancodes;
	rename plancodes = plancode;
run;

/*proc export data=STARPLUS_for_analysis*/
/*	outfile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STARPLUS_for_analysis.xlsx"*/
/*	dbms=xlsx*/
/*	replace*/
/*	;*/
/*run;*/



* STAR Kids;
DATA STARKIDS;
	SET QOC22.STARKIDS_HEDIS_ALL;
	rate2 = .;
	if denom ne 0 then rate2 = numer / denom;
RUN;


PROC FREQ DATA=STARKIDS;
	TABLE MEASURENAME POPULATIONNAME;
RUN;

proc contents data=STARKIDS varnum;
run;

%extract(STARKIDS, "Well Care Vst MY22 (WCVMY22)", "/3 to 11 years old/", WCV11);
%extract(STARKIDS, "Well Care Vst MY22 (WCVMY22)", "/12 to 17 years old/", WCV17);
%extract(STARKIDS, "F/U Hosp for MH MY22 (FUHMY22)", "/Total Follow Up within 7 Days/", FUH);
%extract(STARKIDS, "Metabol Antipsy MY22 (APMMY22)", "/Glucose and Chol Combined - All Ages/", APM);

DATA STARKIDS_for_analysis;
	MERGE 
		STARKIDS_WCV11(KEEP=plancodes WCV11 WCV11_den)
		STARKIDS_WCV17(KEEP=plancodes WCV17 WCV17_den)
		STARKIDS_FUH(KEEP=plancodes FUH FUH_den)
		STARKIDS_APM(KEEP=plancodes APM APM_den)
		;
	BY plancodes;
	rename plancodes = plancode;
RUN;


/*proc export data=STARKIDS_for_analysis*/
/*	outfile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STARKIDS_for_analysis.xlsx"*/
/*	dbms=xlsx*/
/*	replace*/
/*	;*/
/*run;*/






/*proc sql number;*/
/*    select Measurename, SubmeasureName,*/
/*	sum (numer) as TotalNumer_hemo,*/
/*	sum (denom) as TotalDenom_hemo,*/
/*	put(round((calculated TotalNumer_hemo * 1.0) /*/
/*	(calculated TotalDenom_hemo) * 100, 0.1), 5.1) || "%" as Percentage*/
/*    from QOC22.STAR_HEDIS_ALL */
/*	where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)"*/
/*     group by Measurename, SubmeasureName*/
/*	 order by Measurename, SubmeasureName*/
/*	;*/
/*quit;*/
/**/
/*proc sql number;*/
/*    select Measurename, SubmeasureName,*/
/*	sum (numer) as TotalNumer_CDC,*/
/*	sum (denom) as TotalDenom_CDC,*/
/*	put(round((calculated TotalNumer_CDC * 1.0) /*/
/*	(calculated TotalDenom_CDC) * 100, 0.1), 5.1) || "%" as Percentage*/
/*    from QOC21.STAR_HEDIS_ALL */
/*	where Measurename = "Comp Diab N MCR MY21 (CDCMY21B)"*/
/*     group by Measurename, SubmeasureName*/
/*	 order by Measurename, SubmeasureName*/
/*	;*/
/*quit;*/

/* proc freq data = QOC22.STAR_HEDIS_ALL;
	where measurename = "Cervical Cancer MY22 (CCSMY22)";
run; */



*Check the new sub measures name from 2022 HEDIS measure dataset;
/* proc sql;
	select distinct SubmeasureName
	from QOC22.STAR_HEDIS_ALL
	where Measurename = "Eye Exam N MCR MY22 (EEDMY22B)";
quit;

proc sql;
    select distinct Measurename, SubmeasureName
    from QOC22.STAR_HEDIS_ALL 
	where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)"
    order by Measurename, SubmeasureName
	;
quit;

proc sql;
	select Measurename, SubmeasureName, Numer, Denom
	from QOC21.STAR_HEDIS_ALL
	where Measurename = "Cervical Cancer MY21 (CCSMY21)";
quit;

proc contents data=QOC22.STAR_HEDIS_ALL varnum;
run;

proc freq data=QOC21.STAR_HEDIS_ALL nlevels;
	table PopulationName1 /list;
run;

proc sql;
	select count(*) as n_row
	from QOC22.STAR_HEDIS_ALL
	where Measurename = "Cervical Cancer MY22 (CCSMY22)"
	;
quit;

proc sql;
	select PopulationName1
		,count(*) as n_row
	from QOC22.STAR_HEDIS_ALL
	where Measurename = "Cervical Cancer MY22 (CCSMY22)"
	group by PopulationName1
	;
quit; */

/* proc sql number;
	select Measurename, SubmeasureName, Numer, Denom
	from QOC21.STAR_HEDIS_ALL
	where Measurename = "Cervical Cancer MY21 (CCSMY21)";
quit;

proc sql number;
	select Measurename, SubmeasureName, Numer, Denom
	from QOC22.STAR_HEDIS_ALL
	where Measurename = "Cervical Cancer MY22 (CCSMY22)";
quit; */



/* proc print data = QOC22.STARPLUS_HEDIS_ALL (obs=10);
run;

proc contents data = QOC22.STARPLUS_HEDIS_ALL varnum;
run;

proc sql;
	select distinct Measurename, SubmeasureName
	from QOC22.STARplus_HEDIS_ALL
	where Measurename = "Init Engage SUD MY22 (IETMY22)";
quit;

proc sql;
	select distinct Measurename, SubmeasureName
	from QOC21.STARplus_HEDIS_ALL
	where Measurename = "Init Engage AOD MY21 (IETMY21)";
quit;

proc freq data = QOC22.STARplus_HEDIS_ALL;
	where Measurename = "Init Engage SUD MY22 (IETMY22)"
	AND SubmeasureName = "Initiation total (all ages)";
run; */

/* proc sql;
    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom
    from QOC22.STARplus_HEDIS_ALL
    where Measurename = "Init Engage SUD MY22 (IETMY22)"
    AND SubmeasureName = "Initiation total (65+)"
    group by Measurename, SubmeasureName;
run;

proc sql;
    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom
    from QOC22.STARplus_HEDIS_ALL
    where Measurename = "Init Engage SUD MY22 (IETMY22)"
    AND SubmeasureName = "Initiation total (18-64)"
    group by Measurename, SubmeasureName;
run; */

/* proc sql;
    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom
    from QOC22.STARplus_HEDIS_ALL
    where Measurename = "Init Engage SUD MY22 (IETMY22)"
    AND SubmeasureName = "Initiation total (65+)"
    group by Measurename, SubmeasureName

    UNION ALL

    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom
    from QOC22.STARplus_HEDIS_ALL
    where Measurename = "Init Engage SUD MY22 (IETMY22)"
    AND SubmeasureName = "Initiation total (18-64)"
    group by Measurename, SubmeasureName;

run; */

/* proc sql number;
	select Measurename, SubmeasureName
	from QOC22.STARplus_HEDIS_ALL
    where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)";
quit;

proc sql;
    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom
    from QOC22.STARplus_HEDIS_ALL
    where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)"
    AND SubmeasureName = "Non-Medicare HbA1c Control (<8)"
    group by Measurename, SubmeasureName;
run; */

/* 
proc sql number;
    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom,
		2022 as Year
    from QOC22.STAR_HEDIS_ALL
    where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)"
    AND SubmeasureName = "Non-Medicare HbA1c Control (<8)"
    group by Measurename, SubmeasureName
	

    UNION ALL

    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom,
		2022 as Year
    from QOC22.STAR_HEDIS_ALL
    where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)"
    AND SubmeasureName = "Non-Medicare HbA1c Poor Control (>9)"
    group by Measurename, SubmeasureName

	union all

	select 
	Measurename, 
	SubmeasureName, 
	sum(Numer) as TotalNumer, 
	sum(Denom) as TotalDenom,
	2021 as Year
from QOC21.STAR_HEDIS_ALL
where Measurename = "Comp Diab N MCR MY21 (CDCMY21B)"
AND SubmeasureName = "Non-Medicare HbA1c Adequate Control (<8)"
group by Measurename, SubmeasureName

UNION ALL

select 
	Measurename, 
	SubmeasureName, 
	sum(Numer) as TotalNumer, 
	sum(Denom) as TotalDenom,
	2021 as Year
from QOC21.STAR_HEDIS_ALL
where Measurename = "Comp Diab N MCR MY21 (CDCMY21B)"
AND SubmeasureName = "Non-Medicare HbA1c Control (<=9)"
group by Measurename, SubmeasureName

UNION ALL


select 
	Measurename, 
	SubmeasureName, 
	sum(Numer) as TotalNumer, 
	sum(Denom) as TotalDenom,
	2021 as Year
from QOC21.STAR_HEDIS_ALL
where Measurename = "Comp Diab N MCR MY21 (CDCMY21B)"
AND SubmeasureName = "Non-Medicare HbA1c Poor Control (>9)"
group by Measurename, SubmeasureName

UNION ALL


select 
	Measurename, 
	SubmeasureName, 
	sum(Numer) as TotalNumer, 
	sum(Denom) as TotalDenom,
	2021 as Year
from QOC21.STAR_HEDIS_ALL
where Measurename = "Comp Diab N MCR MY21 (CDCMY21B)"
AND SubmeasureName = "Non-Medicare HbA1c Test"
group by Measurename, SubmeasureName;

quit; */



/* proc sql number;
	select Measurename, SubmeasureName,
	sum(Numer) as TotalNumer, 
    sum(Denom) as TotalDenom
	from QOC21.STAR_HEDIS_ALL
    where Measurename = "Comp Diab N MCR MY21 (CDCMY21B)" AND
	SubmeasureName = "Non-Medicare HbA1c Test"
	group by Measurename, SubmeasureName;
quit; */



/* proc sql;
    select 
        Measurename, 
        SubmeasureName, 
        sum(Numer) as TotalNumer, 
        sum(Denom) as TotalDenom
    from QOC22.STARplus_HEDIS_ALL
    where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)"
    AND SubmeasureName = "Non-Medicare HbA1c Poor Control (>9)"
    group by Measurename, SubmeasureName;
run; */
