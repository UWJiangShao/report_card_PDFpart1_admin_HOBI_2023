## Run this file in R.
## You may need to install packages: cluster, data.table, tidyverse, openxlsx.


## Define the custom functions.
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\RetainReliable.R")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\kmeans_optimum.r")
source("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Program\\Function\\PercentileAdjust.R")

## Read in source file
outdir <- "C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data"
infile <- paste(outdir, "STARKIDS_for_analysis.xlsx", sep = "/")
admin_var <- c("WCV11", "WCV17", "FUH", "APM")
SK23_wb <- loadWorkbook(infile)
SK23_admin <- read.xlsx(SK23_wb, sheet=1)

##omit total, LD, and non-reliable
SK23_admin <- subset(SK23_admin, !(SK23_admin$plancode %in% c("TX", "Texas", "Total")))
for(avar in admin_var){
  SK23_admin[[match(avar, names(SK23_admin))]][which(SK23_admin[match(paste0(avar, "_den"), names(SK23_admin))] <30)] <- NA
}
SK23_admin <- RetainReliable(SK23_admin, outvar = "WCV", varlist = c("WCV11", "WCV17"))
SK23_admin <- RetainReliable(SK23_admin, outvar = "FUH", varlist = "FUH")
SK23_admin <- RetainReliable(SK23_admin, outvar = "APM", varlist = "APM")


## Calculate clusters
SK23_wb <- kmeans_opt(SK23_admin, outwb = SK23_wb, descr = "SK23_admin", varlist = admin_var)


## assign ratings by cluster adjusted for national percentiles
SK23_admin <- read.xlsx(SK23_wb, sheet="SK23_admin")

NB <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\Benchmarks2022.xlsx")

# read for statewide average
SW <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Data\\Temp_Data\\STATEWIDE_AVERAGE.xlsx")

for (i in seq_along(admin_var)) {
  
  cat(admin_var[i], "Statewide:", 
      SW$rate[SW$program == "STARKIDS" & SW$outname == admin_var[i]], 
      "National:", c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))),  "\n")
  
  SK23_admin <- PercentileAdjust(SK23_admin, 
                                 admin_var[i], 
                                 statewide = SW$rate[SW$program == "STARKIDS" & SW$outname == admin_var[i]], 
                                 percentiles = c(as.numeric(unlist(strsplit(NB$Outpercentile[NB$MeasureShort == admin_var[i]], ",")))))
}



# SK23_admin <- PercentileAdjust(SK23_admin, "WCV11", statewide = 66.06, percentiles = c(45.99, 50.83, 64.19, 68.94))
# SK23_admin <- PercentileAdjust(SK23_admin, "WCV17", statewide = 60.47, percentiles = c(39.4, 44.72, 58.47, 64.23))
# SK23_admin <- PercentileAdjust(SK23_admin, "FUH", statewide = 42.38, percentiles = c(22.94, 29.97, 46.02, 54.55))
# SK23_admin <- PercentileAdjust(SK23_admin, "APM", statewide = 36.73, percentiles = c(24.51, 28.07, 42.55, 51.69))


## Output table with input data plus clusters, centers, and ratings
writeData(wb = SK23_wb, sheet = "SK23_admin", x = SK23_admin)
saveWorkbook(SK23_wb, infile, overwrite = TRUE)

