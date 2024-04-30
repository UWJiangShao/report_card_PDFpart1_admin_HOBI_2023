* when import external CSV file, please add the Valid name = V7 option since the variable name might not working as expected;

OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MLOGIC MPRINT SYMBOLGEN VALIDVARNAME= V7;


* Extract average, 10th, 25th, 75th, and 90th percentiles from national benchmark;

%LET JOB = P13;



proc import datafile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Raw_Data\MY2022 HEDIS Percentiles_Medicaid.csv"
	dbms=csv
	out=Percentiles
	replace
	;
	GUESSINGROWS=MAX;
run;


proc contents data=Percentiles varnum;
run;

proc freq data=Percentiles;
	* where MeasureNameAbbreviation in ('AAP','ADD','AMR','APM','BCS','CCS','CDC','CIS','FUH','IET','IMA','PCE','PPC','SPR','W15','W34','WCC');
	table BenchmarkCategory MeasureDomain;
	table MeasureNameAbbreviation*MeasureName /list;
run;

proc format;
	value $shortname_f
		"Well-Child Visits in the First 30 Months of Life (15 Months-30 Months)"
			= "W3030"
		"Well-Child Visits in the First 30 Months of Life (First 15 Months)"
			= "W3015"
		"Child and Adolescent Well-Care Visits (3-11)"
			= "WCV11"
		"Child and Adolescent Well-Care Visits (12-17)"
			= "WCV17"
		"Childhood Immunization Status - Combo 10"
			= "CIS"
		"Immunizations for Adolescents - Combination 2"
			= "IMA"
		/* "Asthma Medication Ratio (12-18)"
			= "AMR18"
		"Asthma Medication Ratio (5-11)"
			= "AMR11" */
		"Asthma Medication Ratio (Total)"
			= "AMR"
		"Follow-Up Care for Children Prescribed ADHD Medication - Initiation Phase"
			= "ADD"
		"Prenatal and Postpartum Care - Postpartum Care"
			= "PPCpost"
		"Prenatal and Postpartum Care - Timeliness of Prenatal Care"
			= "PPCpre"
		"Adults' Access to Preventive/Ambulatory Health Services (Total)"
			= "AAP"
		"Cervical Cancer Screening"
			= "CCS"
		"Antidepressant Medication Management - Effective Acute Phase Treatment"
			= "AMM"
		"Follow-Up After Hospitalization For Mental Illness - 7 days (Total)"
			= "FUH"
		"Kidney Health Evaluation for Patients With Diabetes (Total)"
			= "KED"
		"Eye Exam for Patients With Diabetes"
			= "EED"
		"Breast Cancer Screening"
			= "BCS"
		"Initiation and Engagement of Substance Use Disorder Treatment - Initiation of SUD Treatment - Total (18-64)"
			= "IET"
		"Pharmacotherapy Management of COPD Exacerbation - Bronchodilator "
			= "PCEbronch"
		"Pharmacotherapy Management of COPD Exacerbation - Systemic Corticosteroid"
			= "PCEcort"
		"Use of Spirometry Testing in the Assessment and Diagnosis of COPD"
			= "SPR"
		"Metabolic Monitoring for Children and Adolescents on Antipsychotics - Blood Glucose and Cholesterol Testing (Total)"
			= "APM"
			;
/*	value $chip_f*/
/*		"W3030" = "00.W3030"*/
/*		"WCV11" = "01.WCV11"*/
/*		"WCV17" = "02.WCV17"*/
/*		"CIS" = "03.CIS"*/
/*		"IMA" = "04.IMA"*/
/*		"AMRTot" = "05.AMRTot"*/
/*		"ADD" = "06.ADD"*/
/*		;*/
	value $sc_f
		"W3015" = "00.W3015"
		"W3030" = "01.W3030"
		"WCV11" = "02.WCV11"
		"WCV17" = "03.WCV17"
		"CIS" = "04.CIS"
		"IMA" = "05.IMA"
		"AMR" = "06.AMR"
		"ADD" = "07.ADD"
		;
	value $sa_f
		"PPCpre" = "00.PPCpre"
		"PPCpost" = "01.PPCpost"
		"AAP" = "02.AAP"
		"CCS" = "03.CCS"
		"AMM" = "04.AMM"
		"FUH" = "05.FUH"
		"KED" = "06.KED"
		"EED" = "07.EED"
		;
	value $sp_f
		"AAP" = "00.AAP"
		"BCS" = "01.BCS"
		"CCS" = "02.CCS"
		"AMM" = "03.AMM"
		"FUH" = "04.FUH"
		"IET" = "05.IET"
		"PCEbronch" = "06.PCEbronch"
		"PCEcort" = "07.PCEcort"
		"SPR" = "08.SPR"
		"KED" = "09.KED"
		"EED" = "10.EED"
		;
	value $sk_f
		"WCV11" = "00.WCV11"
		"WCV17" = "01.WCV17"
		"FUH" = "02.FUH"
		"APM" = "03.APM"
		;
run;

proc sql number;
select distinct MEASURENAME
from Percentiles;
quit;

data Percentiles_need;
	set Percentiles;
	where 
		BenchmarkCategory = "National - HMO"
		and MEASURENAME in: (
				"Well-Child Visits in the First 30 Months of Life (15 Months-30 Months)"
				"Well-Child Visits in the First 30 Months of Life (First 15 Months)"
				"Child and Adolescent Well-Care Visits (3-11)"
				"Child and Adolescent Well-Care Visits (12-17)"
				"Childhood Immunization Status - Combo 10"
				"Immunizations for Adolescents - Combination 2"
/*				"Asthma Medication Ratio (12-18)"*/
/*				"Asthma Medication Ratio (5-11)"*/
				"Asthma Medication Ratio (Total)"
				"Follow-Up Care for Children Prescribed ADHD Medication - Initiation Phase"
				"Prenatal and Postpartum Care - Postpartum Care"
				"Prenatal and Postpartum Care - Timeliness of Prenatal Care"
				"Adults' Access to Preventive/Ambulatory Health Services (Total)"
				"Cervical Cancer Screening"
				"Antidepressant Medication Management - Effective Acute Phase Treatment"
				"Follow-Up After Hospitalization For Mental Illness - 7 days (Total)"
				"Kidney Health Evaluation for Patients With Diabetes (Total)"
				"Eye Exam for Patients With Diabetes"
				"Breast Cancer Screening"
				"Initiation and Engagement of Substance Use Disorder Treatment - Initiation of SUD Treatment - Total (18-64)"
				"Pharmacotherapy Management of COPD Exacerbation - Bronchodilator "
				"Pharmacotherapy Management of COPD Exacerbation - Systemic Corticosteroid"
				"Use of Spirometry Testing in the Assessment and Diagnosis of COPD"
				"Metabolic Monitoring for Children and Adolescents on Antipsychotics - Blood Glucose and Cholesterol Testing (Total)"
				)
				/* Note that we dont use ECDS (electronic clinical data system) for this year; possible measure change in the future */
				and MeasureNameAbbreviation ne 'BCS-E';

	Outpercentile = cat(_10thPercentile, ", ", _25thPercentile, ", ", _75thPercentile, ", ", _90thPercentile);
	
	MeasureShort = put(MeasureName, shortname_f.);

	keep MeasureNameAbbreviation MeasureName MeasureShort AverageRate Outpercentile _10thPercentile _25thPercentile _75thPercentile _90thPercentile;
run;


proc contents data= Percentiles varnum;
run;

proc print data=Percentiles;
	where 
		BenchmarkCategory = "National - HMO"
		and MEASURENAME in: ("Well-Child Visits in the First 30 Months of Life (15 Months-30 Months)");
run;


proc export data=Percentiles_need
	outfile="C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data\Benchmarks2022.xlsx"
	dbms=xlsx
	replace
	;
run;

/*data chip_percentile;*/
/*	set Percentiles_need;*/
/*	where MeasureShort in ("W3030","WCV11","WCV17","CIS","IMA","AMRTot","ADD");*/
/*	MeasureOrder = put(MeasureShort, chip_f.);*/
/*	keep MeasureOrder Outpercentile;*/
/*run;*/

data starchild_percentile;
	set Percentiles_need;
	where MeasureShort in ("W3015" "W3030" "WCV11" "WCV17" "CIS" "IMA" "AMR" "ADD");
	MeasureOrder = put(MeasureShort, sc_f.);
	keep MeasureOrder Outpercentile;
run;

data staradult_percentile;
	set Percentiles_need;
	where MeasureShort in ("PPCpre" "PPCpost" "AAP" "CCS" "AMM" "FUH" "KED" "EED");
	MeasureOrder = put(MeasureShort, sa_f.);
	keep MeasureOrder Outpercentile;
run;

data starplus_percentile;
	set Percentiles_need;
	where MeasureShort in ("AAP" "BCS" "CCS" "AMM" "FUH" "IET" "PCEbronch" "PCEcort" "SPR" "KED" "EED");
	MeasureOrder = put(MeasureShort, sp_f.);
	keep MeasureOrder Outpercentile;
run;

data starkids_percentile;
	set Percentiles_need;
	where MeasureShort in ("WCV11" "WCV17" "FUH" "APM");
	MeasureOrder = put(MeasureShort, sk_f.);
	keep MeasureOrder Outpercentile;
run;

/*proc sort data=chip_percentile; by MeasureOrder; run;*/
proc sort data=starchild_percentile; by MeasureOrder; run;
proc sort data=staradult_percentile; by MeasureOrder; run;
proc sort data=starplus_percentile; by MeasureOrder; run;
proc sort data=starkids_percentile; by MeasureOrder; run;

/*proc print data=chip_percentile;*/
/*	var MeasureOrder Outpercentile;*/
/*run;*/
proc print data=starchild_percentile;
	var MeasureOrder Outpercentile;
run;
proc print data=staradult_percentile;
	var MeasureOrder Outpercentile;
run;
proc print data=starplus_percentile;
	var MeasureOrder Outpercentile;
run;
proc print data=starkids_percentile;
	var MeasureOrder Outpercentile;
run;