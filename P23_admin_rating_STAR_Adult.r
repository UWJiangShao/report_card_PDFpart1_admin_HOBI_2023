## Run this file in R.
## You may need to install packages: cluster, data.table, tidyverse, openxlsx.


## Define the custom functions.
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\RetainReliable.R")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\kmeans_optimum.r")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\PercentileAdjust.R")

## Read in source file
outdir <- "C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data"
infile <- paste(outdir, "STAR_Adult_for_analysis.xlsx", sep = "/")

#Change this line for different measures 
admin_var <- c("PPCpre", "PPCpost", "AAP", "CCS", "AMM", "FUH", "KED", "EED")

SA23_wb <- loadWorkbook(infile)
SA23_admin <- read.xlsx(SA23_wb, sheet=1)

##omit total, LD and non-reliable
SA23_admin <- subset(SA23_admin, !(SA23_admin$plancode %in% c("TX", "Texas", "Total")))
for(avar in admin_var){
  SA23_admin[[match(avar, names(SA23_admin))]][which(SA23_admin[match(paste0(avar, "_den"), names(SA23_admin))] <30)] <- NA
}


SA23_admin <- RetainReliable(SA23_admin, outvar = "PPCpre", varlist = "PPCpre")
SA23_admin <- RetainReliable(SA23_admin, outvar = "PPCpost", varlist = "PPCpost")
SA23_admin <- RetainReliable(SA23_admin, outvar = "AAP", varlist = "AAP")
SA23_admin <- RetainReliable(SA23_admin, outvar = "CCS", varlist = "CCS")
SA23_admin <- RetainReliable(SA23_admin, outvar = "BHcomp", varlist = c("AMM", "FUH"))
SA23_admin <- RetainReliable(SA23_admin, outvar = "CDCcomp", varlist = c("KED", "EED"))


## Calculate clusters
SA23_wb <- kmeans_opt(SA23_admin, outwb = SA23_wb, descr = "SA23_admin", varlist = admin_var)


## assign numeric ratings, potentially adjusted for national benchmarks
SA23_admin <- read.xlsx(SA23_wb, sheet="SA23_admin")


# Percentile Loop:
NB <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\Benchmarks2022.xlsx")

# read for statewide average
SW <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\STATEWIDE_AVERAGE.xlsx")

for (i in seq_along(admin_var)) {
  
  cat(admin_var[i], "Statewide:", 
      SW$rate[SW$program == "STAR_Adult" & SW$outname == admin_var[i]], 
      "National:", c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))),  "\n")
  
  SA23_admin <- PercentileAdjust(SA23_admin, 
                                 admin_var[i], 
                                 statewide = SW$rate[SW$program == "STAR_Adult" & SW$outname == admin_var[i]], 
                                 percentiles = c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))))
}


# SA23_admin <- PercentileAdjust(SA23_admin, admin_var[1], statewide = NB$AverageRate[NB$MeasureShort == admin_var[1]], 
#                                percentiles = c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[1]], ",")))))
# 
# SA23_admin <- PercentileAdjust(SA23_admin, "PPCpost", statewide = 68.55, percentiles = c(64.57, 72.87, 81.27, 84.18))
# 
# 
# SA23_admin <- PercentileAdjust(SA23_admin, "AAP", statewide = 70.50, percentiles = c(65.28, 70.93, 80.86, 84.53))
# SA23_admin <- PercentileAdjust(SA23_admin, "CCS", statewide = 60.95, percentiles = c(42.71, 52.39, 62.53, 66.88))
# SA23_admin <- PercentileAdjust(SA23_admin, "AMM", statewide = 50.33, percentiles = c(51.31, 56.16, 64.9, 71.26))
# SA23_admin <- PercentileAdjust(SA23_admin, "FUH", statewide = 37.88, percentiles = c(22.94, 29.97, 46.02, 54.55))
# SA23_admin <- PercentileAdjust(SA23_admin, "KED", statewide = 22.78, percentiles = c(21.05, 26.87, 40.6, 46.76))


# SA23_admin <- PercentileAdjust(SA23_admin, "CDCtest", statewide = 70.33, percentiles = c(79.44, 82.73, 88.32, 90.51))
# SA23_admin <- PercentileAdjust(SA23_admin, "CDCeye", statewide = 38.19, percentiles = c(38.2, 45.01, 56.51, 63.75))


## Output table with input data plus clusters, centers, and ratings
writeData(wb = SA23_wb, sheet = "SA23_admin", x = SA23_admin)
saveWorkbook(SA23_wb, infile, overwrite = TRUE)

