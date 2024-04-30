OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MLOGIC MPRINT SYMBOLGEN;


LIBNAME QOC22 "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Raw_Data";
LIBNAME OUT "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\2. Admin\Data\Temp_Data";
LIBNAME QOC21 "C:\Users\jiang.shao\Dropbox (UFL)\MCO Report Card - 2024\Program\old\2. Admin\Data\Raw_Data";

proc sql;
	select distinct Measurename
	from QOC22.STAR_HEDIS_ALL
quit; 

/* proc sql;
    select distinct SubmeasureName
    from QOC22.STARPLUS_HEDIS_ALL 
    order by SubmeasureName
	;
quit;
 */
proc sql;
	select distinct SubmeasureName
	from QOC22.STAR_HEDIS_ALL
	where Measurename = "HbA1c C Non-MCR MY22 (HBDMY22B)";
quit; 




* playground;

/* %LET JOB = T01;

LIBNAME QOC22 "..\Data\Raw_Data";

data df_QOC22;
	set qoc22.star_hedis_all;
run;

proc contents data=df_QOC22 varnum;
run;


proc freq data=df_QOC22;
	table measurename;
run;


ods html file="&job..html";


proc sql;
	select distinct Measurename, SubmeasureName
	from df_QOC22
	where PopulationName = 'ALL' and SUPPLEMENTAL_NUMERATOR > 0
	;
quit;

proc print data=df_QOC22;
	where Measurename = "Pren Post Care MY22 (PPCMY22)";
	var 
		PopulationName
		FlowchartName
		Measurename
		SubmeasureName
		ADMINISTRATIVE_NUMERATOR
		SUPPLEMENTAL_NUMERATOR
		Numer
		Denom
		rate
		;
run;

ods html close; */