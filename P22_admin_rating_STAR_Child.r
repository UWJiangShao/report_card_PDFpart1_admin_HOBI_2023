## Run this file in R.
## You may need to install packages: cluster, data.table, tidyverse, openxlsx.


## Define the custom functions.
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\RetainReliable.R")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\kmeans_optimum.r")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\PercentileAdjust.R")

## Read in source file
outdir <- "C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data"
infile <- paste(outdir, "STAR_Child_for_analysis.xlsx", sep = "/")
admin_var <- c("W3015", "W3030", "WCV11", "WCV17", "CIS", "IMA", "AMR", "ADD")
SC23_wb <- loadWorkbook(infile)
SC23_admin <- read.xlsx(SC23_wb, sheet=1)

##omit total, LD, and non-reliable
SC23_admin <- subset(SC23_admin, !(SC23_admin$plancode %in% c("TX", "Texas", "Total")))
for(avar in admin_var){
  SC23_admin[[match(avar, names(SC23_admin))]][which(SC23_admin[match(paste0(avar, "_den"), names(SC23_admin))] <30)] <- NA
}
SC23_admin <- RetainReliable(SC23_admin, outvar = "W30comp", varlist = c("W3015", "W3030"))
SC23_admin <- RetainReliable(SC23_admin, outvar = "WCVcomp", varlist = c("WCV11", "WCV17"))
SC23_admin <- RetainReliable(SC23_admin, outvar = "vacc", varlist = c("CIS", "IMA"))
SC23_admin <- RetainReliable(SC23_admin, outvar = "AMR", varlist = "AMR")
SC23_admin <- RetainReliable(SC23_admin, outvar = "ADD", varlist = "ADD")


## Calculate clusters
SC23_wb <- kmeans_opt(SC23_admin, outwb = SC23_wb, descr = "SC23_admin", varlist = admin_var)


## assign numeric ratings, potentially adjusted for national benchmarks
SC23_admin <- read.xlsx(SC23_wb, sheet="SC23_admin")

# Percentile Loop:
# read for national benchmark
NB <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\Benchmarks2022.xlsx")

# read for statewide average
SW <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\STATEWIDE_AVERAGE.xlsx")

for (i in seq_along(admin_var)) {
  
  cat(admin_var[i], "Statewide:", 
      SW$rate[SW$program == "STAR_Child" & SW$outname == admin_var[i]], 
      "National:", c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))),  "\n")
  
  SC23_admin <- PercentileAdjust(SC23_admin, 
                                 admin_var[i], 
                                 statewide = SW$rate[SW$program == "STAR_Child" & SW$outname == admin_var[i]], 
                                 percentiles = c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))))
}

# SC23_admin <- PercentileAdjust(SC23_admin, "W3015", statewide = 59.09, percentiles = c(41.16, 49.88, 61.19, 67.56))
# SC23_admin <- PercentileAdjust(SC23_admin, "W3030", statewide = 70.56, percentiles = c(54.43, 60.53, 72.24, 78.07))
# SC23_admin <- PercentileAdjust(SC23_admin, "WCV11", statewide = 64.43, percentiles = c(45.99, 50.83, 64.19, 68.94))
# SC23_admin <- PercentileAdjust(SC23_admin, "WCV17", statewide = 60.75, percentiles = c(39.4, 44.72, 58.47, 64.23))
# SC23_admin <- PercentileAdjust(SC23_admin, "CIS", statewide = 26.23, percentiles = c(23.71, 28.95, 42.09, 49.76))
# SC23_admin <- PercentileAdjust(SC23_admin, "IMA", statewide = 34.66, percentiles = c(25.79, 30.41, 41.12, 48.42))
# SC23_admin <- PercentileAdjust(SC23_admin, "AMR", statewide = 71.45, percentiles = c(54.6, 59.94, 69.67, 74.21))
# SC23_admin <- PercentileAdjust(SC23_admin, "ADD", statewide = 39.09, percentiles = c(29.79, 35.05, 44.17, 50))


## Output table with input data plus clusters, centers, and ratings
writeData(wb = SC23_wb, sheet = "SC23_admin", x = SC23_admin)
saveWorkbook(SC23_wb, infile, overwrite = TRUE)

