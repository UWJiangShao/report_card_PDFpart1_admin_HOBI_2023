## Run this file in R.
## You may need to install packages: cluster, data.table, tidyverse, openxlsx.


## Define the custom functions.
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\RetainReliable.R")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\kmeans_optimum.r")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\PercentileAdjust.R")

## Read in source file
outdir <- "C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data"
infile <- paste(outdir, "STARPLUS_for_analysis.xlsx", sep = "/")
admin_var <- c("AAP", "BCS", "CCS", "AMM", "FUH", "IET", "PCEbronch", "PCEcort", "SPR", "KED", "EED")
SP23_wb <- loadWorkbook(infile)
SP23_admin <- read.xlsx(SP23_wb, sheet=1)

##omit total, LD, and non-reliable
SP23_admin <- subset(SP23_admin, !(SP23_admin$plancode %in% c("TX", "Texas", "Total")))
for(avar in admin_var){
  SP23_admin[[match(avar, names(SP23_admin))]][which(SP23_admin[match(paste0(avar, "_den"), names(SP23_admin))] <30)] <- NA
}
SP23_admin <- RetainReliable(SP23_admin, outvar = "AAP", varlist = "AAP")
SP23_admin <- RetainReliable(SP23_admin, outvar = "cancer", varlist = c("BCS", "CCS"))
SP23_admin <- RetainReliable(SP23_admin, outvar = "BHcomp", varlist = c("AMM", "FUH"))
SP23_admin <- RetainReliable(SP23_admin, outvar = "IET", varlist = "IET")
SP23_admin <- RetainReliable(SP23_admin, outvar = "COPD", varlist = c("PCEbronch", "PCEcort", "SPR"))
SP23_admin <- RetainReliable(SP23_admin, outvar = "CDCcomp", varlist = c("KED", "EED"))

## Calculate clusters
SP23_wb <- kmeans_opt(SP23_admin, outwb = SP23_wb, descr = "SP23_admin", varlist = admin_var)


## assign numeric ratings, potentially adjusted for national benchmarks
SP23_admin <- read.xlsx(SP23_wb, sheet="SP23_admin")


# Percentile Loop:
NB <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\Benchmarks2022.xlsx")

# read for statewide average
SW <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\STATEWIDE_AVERAGE.xlsx")

for (i in seq_along(admin_var)) {
  
  cat(admin_var[i], "Statewide:", 
      SW$rate[SW$program == "STARPLUS" & SW$outname == admin_var[i]], 
      "National:", c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))),  "\n")
  
  SP23_admin <- PercentileAdjust(SP23_admin, 
                                 admin_var[i], 
                                 statewide = SW$rate[SW$program == "STARPLUS" & SW$outname == admin_var[i]], 
                                 percentiles = c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))))
}


# SP23_admin <- PercentileAdjust(SP23_admin, "AAP", statewide = 81.90, percentiles = c(65.28, 70.93, 80.86, 84.53))
# SP23_admin <- PercentileAdjust(SP23_admin, "BCS", statewide = 44.41, percentiles = c(40.72, 45.23, 56.52, 61.27))
# SP23_admin <- PercentileAdjust(SP23_admin, "CCS", statewide = 37.76, percentiles = c(42.71, 52.39, 62.53, 66.88))
# SP23_admin <- PercentileAdjust(SP23_admin, "AMM", statewide = 57.52, percentiles = c(51.31, 56.16, 64.9, 71.26))
# SP23_admin <- PercentileAdjust(SP23_admin, "FUH", statewide = 33.11, percentiles = c(22.94, 29.97, 46.02, 54.55))
# SP23_admin <- PercentileAdjust(SP23_admin, "IET", statewide = 40.22, percentiles = c(35.78, 40.14, 48.62, 52.93))
# SP23_admin <- PercentileAdjust(SP23_admin, "PCEbronch", statewide = 86.24, percentiles = c(67.19, 80.33, 88.67, 91.22))
# SP23_admin <- PercentileAdjust(SP23_admin, "PCEcort", statewide = 69.33, percentiles = c(55.58, 64.66, 76.87, 82.81))
# SP23_admin <- PercentileAdjust(SP23_admin, "SPR", statewide = 19.43, percentiles = c(16.86, 20.47, 28.24, 33.97))
# SP23_admin <- PercentileAdjust(SP23_admin, "KED", statewide = 28.67, percentiles = c(21.05, 26.87, 40.6, 46.76))
# SP23_admin <- PercentileAdjust(SP23_admin, "CDCtest", statewide = 82.16, percentiles = c(79.44, 82.73, 88.32, 90.51))
# SP23_admin <- PercentileAdjust(SP23_admin, "CDCeye", statewide = 49.17, percentiles = c(38.2, 45.01, 56.51, 63.75))


## Output table with input data plus clusters, centers, and ratings
writeData(wb = SP23_wb, sheet = "SP23_admin", x = SP23_admin)
saveWorkbook(SP23_wb, infile, overwrite = TRUE)

