OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MLOGIC MPRINT SYMBOLGEN noxwait noxsync;

* Formatting results;
* Using DDE technique; 

%LET JOB = P32;

proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\raw_Data\plancode.xlsx"
	dbms=XLSX
	out=plancode
	;
run;

proc contents data=plancode varnum;
run;


*** ------ STAR Child prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\temp_Data\STAR_Child_for_analysis.xlsx"
	dbms=XLSX
	out=STAR_Child
	;
	sheet="SC23_admin";
run;

proc contents data=STAR_Child varnum;
run;

data STAR_Child;
	set STAR_Child;
	plancode = compress(plancode, "()");
	
	W30comp_rat = round(mean(W3015_rat, W3030_rat), 0.5);
	WCVcomp_rat = round(mean(WCV11_rat,WCV17_rat), 0.5);
	vacc_rat = round(mean(CIS_rat, IMA_rat), 0.5);

run;

proc sort data=STAR_Child; by plancode; run;

data STAR_Child;
	merge STAR_Child(in=a) plancode(keep=MCONAME PLANCODE SERVICEAREA);
	by plancode;
	if a;
run;

proc sort data=STAR_Child; by SERVICEAREA MCONAME; run;


*** ------ STAR Adult prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STAR_Adult_for_analysis.xlsx"
	dbms=XLSX
	out=STAR_Adult
	;
	sheet="SA23_admin";
run;

proc contents data=STAR_Adult varnum;
run;

data STAR_Adult;
	set STAR_Adult;
	plancode = compress(plancode, "()");

	BHcomp_rat = round(mean(AMM_rat, FUH_rat), 0.5);
	CDCcomp_rat = round(mean(KED_rat, EED_rat), 0.5);

run;

proc sort data=STAR_Adult; by plancode; run;

data STAR_Adult;
	merge STAR_Adult(in=a) plancode(keep=MCONAME PLANCODE SERVICEAREA);
	by plancode;
	if a;
run;

proc sort data=STAR_Adult; by SERVICEAREA MCONAME; run;


*** ------ STAR + PLUS prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STARPLUS_for_analysis.xlsx"
	dbms=XLSX
	out=STARPLUS
	;
	sheet="SP23_admin";
run;

proc contents data=STARPLUS varnum;
run;

data STARPLUS;
	set STARPLUS;
	plancode = compress(plancode, "()");

	cancer_rat = round(mean(BCS_rat, CCS_rat), 0.5);
	BHcomp_rat = round(mean(AMM_rat, FUH_rat), 0.5);
	COPD_rat = round(mean(mean(PCEcort_rat, PCEbronch_rat), SPR_rat), 0.5);
	CDCcomp_rat = round(mean(KED_rat, EED_rat), 0.5);

run;

proc sort data=STARPLUS; by plancode; run;

data STARPLUS;
	merge STARPLUS(in=a) plancode(keep=MCONAME PLANCODE SERVICEAREA);
	by plancode;
	if a;
run;

proc sort data=STARPLUS; by SERVICEAREA MCONAME; run;


*** ------ STAR Kids prepare data ----------------------------------------------------------------------------------------------------------;
proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\STARKids_for_analysis.xlsx"
	dbms=XLSX
	out=STARKids
	;
	sheet="SK23_admin";
run;

proc contents data=STARKids varnum;
run;

data STARKids;
	set STARKids;
	plancode = compress(plancode, "()");

	WCVcomp_rat = round(mean(WCV11_rat,WCV17_rat), 0.5);

run;

proc sort data=STARKids; by plancode; run;

data STARKids;
	merge STARKids(in=a) plancode(keep=MCONAME PLANCODE SERVICEAREA);
	by plancode;
	if a;
run;

proc sort data=STARKids; by SERVICEAREA MCONAME; run;


proc freq data=STAR_Child nlevels;
	table W30comp_rat /list out=RG_SC_W30;
	table WCVcomp_rat /list out=RG_SC_WCV;
	table vacc_rat /list out=RG_SC_Vacc;
	table AMR_center*AMR_rat /list out=RG_SC_AMR;
	table ADD_center*ADD_rat /list out=RG_SC_ADD;
run;

proc freq data=STAR_Adult nlevels;
	table PPCpre_center*PPCpre_rat /list out=RG_SA_PPCpre;
	table PPCpost_center*PPCpost_rat /list out=RG_SA_PPCpost;
	table AAP_center*AAP_rat /list out=RG_SA_AAP;
	table CCS_center*CCS_rat /list out=RG_SA_CCS;
	table BHcomp_rat /list out=RG_SA_BH;
	table CDCcomp_rat /list out=RG_SA_CDCcomp;
run;

proc freq data=STARPLUS nlevels;
	table AAP_center*AAP_rat /list out=RG_SP_AAP;
	table cancer_rat /list out=RG_SP_Cancer;
	table BHcomp_rat /list out=RG_SP_BH;
	table IET_center*IET_rat /list out=RG_SP_IET;
	table COPD_rat /list out=RG_SP_COPD;
	table CDCcomp_rat /list out=RG_SP_CDCcomp;
run;

proc freq data=STARKids nlevels;
	table WCVcomp_rat /list out=RG_SK_WCV;
	table FUH_center*FUH_rat /list out=RG_SK_FUH;
	table APM_center*APM_rat /list out=RG_SK_APM;
run;



** ---- Exporting using DDE --------------------------------------------------------------------;
filename ddeopen DDE 'Excel|system';

* template file;
x '"C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Raw_Data\MCO Report Cards - Administrative Ratings Template wNoRating_2023.xlsx"';


filename SC_W30 dde "Excel|STARChild_W30checkups!r3c1:r46c13" notab;
data _null_;
	set STAR_Child;
	file SC_W30;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		W3015_den '09'x W3015 '09'x W3015_center '09'x W3015_rat '09'x 
		W3030_den '09'x W3030 '09'x W3030_center '09'x W3030_rat '09'x 
		W30comp_relb '09'x W30comp_rat
	;
run;

filename SC_WCV dde "Excel|STARChild_WCVcheckups!r3c1:r46c13" notab;
data _null_;
	set STAR_Child;
	file SC_WCV;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		WCV11_den '09'x WCV11 '09'x WCV11_center '09'x WCV11_rat '09'x 
		WCV17_den '09'x WCV17 '09'x WCV17_center '09'x WCV17_rat '09'x 
		WCVcomp_relb '09'x WCVcomp_rat
	;
run;

filename SC_VAC dde "Excel|STARChild_Vaccines!r3c1:r46c13" notab;
data _null_;
	set STAR_Child;
	file SC_VAC;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		CIS_den '09'x CIS '09'x CIS_center '09'x CIS_rat '09'x 
		IMA_den '09'x IMA '09'x IMA_center '09'x IMA_rat '09'x 
		vacc_relb '09'x vacc_rat
	;
run;

filename SC_AMR dde "Excel|STARChild_Asthma!r3c1:r46c8" notab;
data _null_;
	set STAR_Child;
	file SC_AMR;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		AMR_den '09'x AMR_center '09'x AMR_relb '09'x AMR '09'x AMR_rat
	;
run;

filename SC_ADD dde "Excel|STARChild_ADD!r3c1:r46c8" notab;
data _null_;
	set STAR_Child;
	file SC_ADD;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		ADD_den '09'x ADD_center '09'x ADD_relb '09'x ADD '09'x ADD_rat
	;
run;

filename SA_Pre dde "Excel|STARAdult_Prenatal!r3c1:r46c8" notab;
data _null_;
	set STAR_Adult;
	file SA_Pre;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		PPCpre_den '09'x PPCpre_center '09'x PPCpre_relb '09'x PPCpre '09'x PPCpre_rat
	;
run;

filename SA_Pot dde "Excel|STARAdult_Postpartum!r3c1:r46c8" notab;
data _null_;
	set STAR_Adult;
	file SA_Pot;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		PPCpost_den '09'x PPCpost_center '09'x PPCpost_relb '09'x PPCpost '09'x PPCpost_rat
	;
run;

filename SA_CUP dde "Excel|STARAdult_Checkups!r3c1:r46c8" notab;
data _null_;
	set STAR_Adult;
	file SA_CUP;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		AAP_den '09'x AAP_center '09'x AAP_relb '09'x AAP '09'x AAP_rat
	;
run;

filename SA_CAN dde "Excel|STARAdult_Cancer!r3c1:r46c8" notab;
data _null_;
	set STAR_Adult;
	file SA_CAN;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		CCS_den '09'x CCS_center '09'x CCS_relb '09'x CCS '09'x CCS_rat
	;
run;

filename SA_BH  dde "Excel|STARAdult_BH!r3c1:r46c13" notab;
data _null_;
	set STAR_Adult;
	file SA_BH;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		AMM_den '09'x AMM '09'x AMM_center '09'x AMM_rat '09'x 
		FUH_den '09'x FUH '09'x FUH_center '09'x FUH_rat '09'x 
		BHcomp_relb '09'x BHcomp_rat
	;
run;

/*Update Sep 27 2023: change the column number from 17 to 13, since we deleted CDC test*/

filename SA_DIA dde "Excel|STARAdult_Diabetes!r3c1:r46c13" notab;
data _null_;
	set STAR_Adult;
	file SA_DIA;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		KED_den '09'x KED '09'x KED_center '09'x KED_rat '09'x 
        EED_den '09'x EED '09'x EED_center '09'x EED_rat '09'x 
		CDCcomp_relb '09'x CDCcomp_rat
	;
run;


filename SP_CUP dde "Excel|STARPLUS_Checkups!r3c1:r31c8" notab;
data _null_;
	set STARPLUS;
	file SP_CUP;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		AAP_den '09'x AAP_center '09'x AAP_relb '09'x AAP '09'x AAP_rat
	;
run;

filename SP_CAN dde "Excel|STARPLUS_Cancer!r3c1:r31c13" notab;
data _null_;
	set STARPLUS;
	file SP_CAN;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		BCS_den '09'x BCS '09'x BCS_center '09'x BCS_rat '09'x 
		CCS_den '09'x CCS '09'x CCS_center '09'x CCS_rat '09'x 
		cancer_relb '09'x cancer_rat		
	;
run;

filename SP_BH  dde "Excel|STARPLUS_BH!r3c1:r31c13" notab;
data _null_;
	set STARPLUS;
	file SP_BH;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		AMM_den '09'x AMM '09'x AMM_center '09'x AMM_rat '09'x 
		FUH_den '09'x FUH '09'x FUH_center '09'x FUH_rat '09'x 
		BHcomp_relb '09'x BHcomp_rat
	;
run;

filename SP_IET dde "Excel|STARPLUS_IET_FollowUp!r3c1:r31c8" notab;
data _null_;
	set STARPLUS;
	file SP_IET;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		IET_den '09'x IET_center '09'x IET_relb '09'x IET '09'x IET_rat
	;
run;

filename SP_COP dde "Excel|STARPLUS_COPD!r3c1:r31c17" notab;
data _null_;
	set STARPLUS;
	file SP_COP;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		PCEcort_den '09'x PCEcort '09'x PCEcort_center '09'x PCEcort_rat '09'x 
		PCEbronch_den '09'x PCEbronch '09'x PCEbronch_center '09'x PCEbronch_rat '09'x 
		SPR_den '09'x SPR '09'x SPR_center '09'x SPR_rat '09'x 
		COPD_relb '09'x COPD_rat
	;
run;

filename SP_DIA dde "Excel|STARPLUS_Diabetes!r3c1:r31c17" notab;
data _null_;
	set STARPLUS;
	file SP_DIA;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		KED_den '09'x KED '09'x KED_center '09'x KED_rat '09'x 
		EED_den '09'x EED '09'x EED_center '09'x EED_rat '09'x 
		CDCcomp_relb '09'x CDCcomp_rat
	;
run;

filename SK_CUP dde "Excel|STARKids_Checkups!r3c1:r30c13" notab;
data _null_;
	set STARKids;
	file SK_CUP;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		WCV11_den '09'x WCV11 '09'x WCV11_center '09'x WCV11_rat '09'x 
		WCV17_den '09'x WCV17 '09'x WCV17_center '09'x WCV17_rat '09'x 
		WCV_relb '09'x WCVcomp_rat
	;
run;

filename SK_BH  dde "Excel|STARKids_BH_FollowUp!r3c1:r30c8" notab;
data _null_;
	set STARKids;
	file SK_BH;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		FUH_den '09'x FUH_center '09'x FUH_relb '09'x FUH '09'x FUH_rat
	;
run;

filename SK_APM dde "Excel|STARKids_Antipsychotics!r3c1:r30c8" notab;
data _null_;
	set STARKids;
	file SK_APM;
	put MCONAME '09'x SERVICEAREA '09'x plancode '09'x
		APM_den '09'x APM_center '09'x APM_relb '09'x APM '09'x APM_rat
	;
run;



filename R_SC_W30 dde "Excel|STARChild_W30checkups!r3c15:r11c16" notab;
data _null_;
	set RG_SC_W30(where=(W30comp_rat ne .));
	file R_SC_W30;
	put W30comp_rat '09'x count;
run;

filename R_SC_WCV dde "Excel|STARChild_WCVcheckups!r3c15:r9c16" notab;
data _null_;
	set RG_SC_WCV(where=(WCVcomp_rat ne .));
	file R_SC_WCV;
	put WCVcomp_rat '09'x count;
run;

filename R_SC_VAC dde "Excel|STARChild_Vaccines!r3c15:r10c16" notab;
data _null_;
	set RG_SC_Vacc(where=(vacc_rat ne .));
	file R_SC_VAC;
	put vacc_rat '09'x count;
run;

filename R_SC_AMR dde "Excel|STARChild_Asthma!r3c10:r7c12" notab;
data _null_;
	set RG_SC_AMR(where=(AMR_rat ne .));
	file R_SC_AMR;
	put AMR_center '09'x AMR_rat '09'x count;
run;

filename R_SC_ADD dde "Excel|STARChild_ADD!r3c10:r7c12" notab;
data _null_;
	set RG_SC_ADD(where=(ADD_rat ne .));
	file R_SC_ADD;
	put ADD_center '09'x ADD_rat '09'x count;
run;

filename R_SA_Pre dde "Excel|STARAdult_Prenatal!r3c10:r7c12" notab;
data _null_;
	set RG_SA_PPCpre(where=(PPCpre_rat ne .));
	file R_SA_Pre;
	put PPCpre_center '09'x PPCpre_rat '09'x count;
run;

filename R_SA_Pot dde "Excel|STARAdult_Postpartum!r3c10:r7c12" notab;
data _null_;
	set RG_SA_PPCpost(where=(PPCpost_rat ne .));
	file R_SA_Pot;
	put PPCpost_center '09'x PPCpost_rat '09'x count;
run;

filename R_SA_CUP dde "Excel|STARAdult_Checkups!r3c10:r7c12" notab;
data _null_;
	set RG_SA_AAP(where=(AAP_rat ne .));
	file R_SA_CUP;
	put AAP_center '09'x AAP_rat '09'x count;
run;

filename R_SA_CAN dde "Excel|STARAdult_Cancer!r3c10:r7c12" notab;
data _null_;
	set RG_SA_CCS(where=(CCS_rat ne .));
	file R_SA_CAN;
	put CCS_center '09'x CCS_rat '09'x count;
run;

filename R_SA_BH  dde "Excel|STARAdult_BH!r3c15:r9c16" notab;
data _null_;
	set RG_SA_BH(where=(BHcomp_rat ne .));
	file R_SA_BH;
	put BHcomp_rat '09'x count;
run;

filename R_SA_DIA dde "Excel|STARAdult_Diabetes!r3c15:r8c16" notab;
data _null_;
	set RG_SA_CDCcomp(where=(CDCcomp_rat ne .));
	file R_SA_DIA;
	put CDCcomp_rat '09'x count;
run;

filename R_SP_CUP dde "Excel|STARPLUS_Checkups!r3c10:r7c12" notab;
data _null_;
	set RG_SP_AAP(where=(AAP_rat ne .));
	file R_SP_CUP;
	put AAP_center '09'x AAP_rat '09'x count;
run;

filename R_SP_CAN dde "Excel|STARPLUS_Cancer!r3c15:r9c16" notab;
data _null_;
	set RG_SP_Cancer(where=(cancer_rat ne .));
	file R_SP_CAN;
	put cancer_rat '09'x count;
run;

filename R_SP_BH  dde "Excel|STARPLUS_BH!r3c15:r9c16" notab;
data _null_;
	set RG_SP_BH(where=(BHcomp_rat ne .));
	file R_SP_BH;
	put BHcomp_rat '09'x count;
run;

filename R_SP_IET dde "Excel|STARPLUS_IET_FollowUp!r3c10:r7c12" notab;
data _null_;
	set RG_SP_IET(where=(IET_rat ne .));
	file R_SP_IET;
	put IET_center '09'x IET_rat '09'x count;
run;

filename R_SP_COP dde "Excel|STARPLUS_COPD!r3c19:r9c20" notab;
data _null_;
	set RG_SP_COPD(where=(COPD_rat ne .));
	file R_SP_COP;
	put COPD_rat '09'x count;
run;

filename R_SP_DIA dde "Excel|STARPLUS_Diabetes!r3c15:r9c16" notab;
data _null_;
	set RG_SP_CDCcomp(where=(CDCcomp_rat ne .));
	file R_SP_DIA;
	put CDCcomp_rat '09'x count;
run;

filename R_SK_CUP dde "Excel|STARKids_Checkups!r3c15:r9c16" notab;
data _null_;
	set RG_SK_WCV(where=(WCVcomp_rat ne .));
	file R_SK_CUP;
	put WCVcomp_rat '09'x count;
run;

filename R_SK_BH  dde "Excel|STARKids_BH_FollowUp!r3c10:r7c12" notab;
data _null_;
	set RG_SK_FUH(where=(FUH_rat ne .));
	file R_SK_BH;
	put FUH_center '09'x FUH_rat '09'x count;
run;

filename R_SK_APM dde "Excel|STARKids_Antipsychotics!r3c10:r7c12" notab;
data _null_;
	set RG_SK_APM(where=(APM_rat ne .));
	file R_SK_APM;
	put APM_center '09'x APM_rat '09'x count;
run;


** ---- file the frequency for No rating --------------------------------------------------;
proc format;
	value rating_f
		. = "No rating"
		;
run;


filename M_SC_W30 dde "Excel|STARChild_W30checkups!r12c15:r12c16" notab;
data _null_;
	set RG_SC_W30(where=(W30comp_rat = .));
	file M_SC_W30;
	put W30comp_rat '09'x count;
	format W30comp_rat rating_f.;
run;

filename M_SC_WCV dde "Excel|STARChild_WCVcheckups!r10c15:r10c16" notab;
data _null_;
	set RG_SC_WCV(where=(WCVcomp_rat = .));
	file M_SC_WCV;
	put WCVcomp_rat '09'x count;
	format WCVcomp_rat rating_f.;
run;

filename M_SC_VAC dde "Excel|STARChild_Vaccines!r11c15:r11c16" notab;
data _null_;
	set RG_SC_Vacc(where=(vacc_rat = .));
	file M_SC_VAC;
	put vacc_rat '09'x count;
	format vacc_rat rating_f.;
run;

filename M_SC_AMR dde "Excel|STARChild_Asthma!r8c11:r8c12" notab;
data _null_;
	set RG_SC_AMR(where=(AMR_rat = .));
	file M_SC_AMR;
	put AMR_rat '09'x count;
	format AMR_rat rating_f.;
run;

filename M_SC_ADD dde "Excel|STARChild_ADD!r8c11:r8c12" notab;
data _null_;
	set RG_SC_ADD(where=(ADD_rat = .));
	file M_SC_ADD;
	put ADD_rat '09'x count;
	format ADD_rat rating_f.;
run;

filename M_SA_Pre dde "Excel|STARAdult_Prenatal!r8c11:r8c12" notab;
data _null_;
	set RG_SA_PPCpre(where=(PPCpre_rat = .));
	file M_SA_Pre;
	put PPCpre_rat '09'x count;
	format PPCpre_rat rating_f.;
run;

filename M_SA_Pot dde "Excel|STARAdult_Postpartum!r8c11:r8c12" notab;
data _null_;
	set RG_SA_PPCpost(where=(PPCpost_rat = .));
	file M_SA_Pot;
	put PPCpost_rat '09'x count;
	format PPCpost_rat rating_f.;
run;

filename M_SA_CUP dde "Excel|STARAdult_Checkups!r8c11:r8c12" notab;
data _null_;
	set RG_SA_AAP(where=(AAP_rat = .));
	file M_SA_CUP;
	put AAP_rat '09'x count;
	format AAP_rat rating_f.;
run;

filename M_SA_CAN dde "Excel|STARAdult_Cancer!r8c11:r8c12" notab;
data _null_;
	set RG_SA_CCS(where=(CCS_rat = .));
	file M_SA_CAN;
	put CCS_rat '09'x count;
	format CCS_rat rating_f.;
run;

filename M_SA_BH  dde "Excel|STARAdult_BH!r10c15:r10c16" notab;
data _null_;
	set RG_SA_BH(where=(BHcomp_rat = .));
	file M_SA_BH;
	put BHcomp_rat '09'x count;
	format BHcomp_rat rating_f.;
run;

filename M_SA_DIA dde "Excel|STARAdult_Diabetes!r9c15:r9c16" notab;
data _null_;
	set RG_SA_CDCcomp(where=(CDCcomp_rat = .));
	file M_SA_DIA;
	put CDCcomp_rat '09'x count;
	format CDCcomp_rat rating_f.;
run;

filename M_SP_CUP dde "Excel|STARPLUS_Checkups!r8c11:r8c12" notab;
data _null_;
	set RG_SP_AAP(where=(AAP_rat = .));
	file M_SP_CUP;
	put AAP_rat '09'x count;
	format AAP_rat rating_f.;
run;

filename M_SP_CAN dde "Excel|STARPLUS_Cancer!r10c15:r10c16" notab;
data _null_;
	set RG_SP_Cancer(where=(cancer_rat = .));
	file M_SP_CAN;
	put cancer_rat '09'x count;
	format cancer_rat rating_f.;
run;

filename M_SP_BH  dde "Excel|STARPLUS_BH!r10c15:r10c16" notab;
data _null_;
	set RG_SP_BH(where=(BHcomp_rat = .));
	file M_SP_BH;
	put BHcomp_rat '09'x count;
	format BHcomp_rat rating_f.;
run;

filename M_SP_IET dde "Excel|STARPLUS_IET_FollowUp!r8c11:r8c12" notab;
data _null_;
	set RG_SP_IET(where=(IET_rat = .));
	file M_SP_IET;
	put IET_rat '09'x count;
	format IET_rat rating_f.;
run;

filename M_SP_COP dde "Excel|STARPLUS_COPD!r10c19:r10c20" notab;
data _null_;
	set RG_SP_COPD(where=(COPD_rat = .));
	file M_SP_COP;
	put COPD_rat '09'x count;
	format COPD_rat rating_f.;
run;

filename M_SP_DIA dde "Excel|STARPLUS_Diabetes!r10c15:r10c16" notab;
data _null_;
	set RG_SP_CDCcomp(where=(CDCcomp_rat = .));
	file M_SP_DIA;
	put CDCcomp_rat '09'x count;
	format CDCcomp_rat rating_f.;
run;

filename M_SK_CUP dde "Excel|STARKids_Checkups!r10c15:r10c16" notab;
data _null_;
	set RG_SK_WCV(where=(WCVcomp_rat = .));
	file M_SK_CUP;
	put WCVcomp_rat '09'x count;
	format WCVcomp_rat rating_f.;
run;

filename M_SK_BH  dde "Excel|STARKids_BH_FollowUp!r8c11:r8c12" notab;
data _null_;
	set RG_SK_FUH(where=(FUH_rat = .));
	file M_SK_BH;
	put FUH_rat '09'x count;
	format FUH_rat rating_f.;
run;

filename M_SK_APM dde "Excel|STARKids_Antipsychotics!r8c11:r8c12" notab;
data _null_;
	set RG_SK_APM(where=(APM_rat = .));
	file M_SK_APM;
	put APM_rat '09'x count;
	format APM_rat rating_f.;
run;



data _null_;
	file ddeopen;
	put '[error(false)]';
	put '[save.as("C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Output\Adminstrative_Ratings_final_corrected_Dec13.xlsx")]';
	put '[file.close(false)]';
run;
