library(dplyr)
library(openxlsx)

# Read in the data
# Report card 2022
SC22 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 22.xlsx", sheet = 1)
SA22 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 22.xlsx", sheet = 2)
SP22 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 22.xlsx", sheet = 3)
SK22 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 22.xlsx", sheet = 4)

#Report card 2023
SC23 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 23.xlsx", sheet = 1)
SA23 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 23.xlsx", sheet = 2)
SP23 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 23.xlsx", sheet = 3)
SK23 <- read.xlsx("C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO report card - 2024\\Program\\2. Admin\\Output\\admin data 23.xlsx", sheet = 4)

transpose_data <- function(df) {
  
  # Extract the core column names (MCO, SA, and Plan Code)
  core_cols <- names(df)[1:3]
  
  measurements <- unique(gsub(".*_", "", names(df)[-c(1:3)]))
  
  dfs <- list()
  
  standard_names <- c("Denominator", "Score", "Nearest.Cluster.Center", "Component.Rating", "Reliability", "Composite.score", "Final.Rating")
  
  for (measurement in measurements) {
    
    cols_for_measurement <- grep(paste0("_", measurement, "$"), names(df), value = TRUE)
    
    present_names <- standard_names[standard_names %in% sub(paste0("_", measurement), "", cols_for_measurement)]
    
    subset_df <- data.frame(matrix(ncol = length(core_cols) + length(standard_names) + 1, nrow = nrow(df)))
    
    names(subset_df) <- c(core_cols, standard_names, "Measurement")
    
    subset_df[, core_cols] <- df[, core_cols]
    
    subset_df[, present_names] <- df[, colnames(df) %in% paste0(present_names, "_", measurement)]
    
    subset_df$Measurement <- measurement
    
    dfs[[measurement]] <- subset_df
  }
  
  result <- do.call(rbind, dfs)
  
  return(result)

}

SC22_new <- transpose_data(SC22)
SA22_new <- transpose_data(SA22)
SP22_new <- transpose_data(SP22)
SK22_new <- transpose_data(SK22)

SC23_new <- transpose_data(SC23)
SA23_new <- transpose_data(SA23)
SP23_new <- transpose_data(SP23)
SK23_new <- transpose_data(SK23)

# Generate the difference table

############


compute_difference <- function(df1, df2, threshold) {
  columns_to_compare <- c("Denominator", "Score", "Nearest.Cluster.Center", "Component.Rating", "Composite.score", "Reliability", "Final.Rating")
  columns_to_convert <- columns_to_compare
  
  for (col in columns_to_convert) {
    df1[[col]] <- as.numeric(as.character(df1[[col]]))
  }
  
  for (col in columns_to_convert) {
    df2[[col]] <- as.numeric(as.character(df2[[col]]))
  }
  
  merged_df <- full_join(df1, df2, by = c("MCO", "Service.Area", "Plan.Code", "Measurement"))
  
  for (col in columns_to_compare) {
    # 2022
    col_x <- paste(col, ".x", sep = "")
    # 2023
    col_y <- paste(col, ".y", sep = "")
    
    if (is.numeric(merged_df[[col_x]]) && is.numeric(merged_df[[col_y]])) {
      diff_value <- abs(as.numeric(merged_df[[col_y]]) - as.numeric(merged_df[[col_x]]))
      merged_df[paste(col, "diff", sep = "_")] <- diff_value
      
      sig_column <- paste(col, "sig", sep = "_")
      condition <- !is.na(diff_value) & !is.na(merged_df[[col_x]]) & merged_df[[col_x]] != 0 & (diff_value / abs(merged_df[[col_x]]) > threshold)
      merged_df[sig_column] <- ifelse(condition, "Yes", "No")
      
    } else {
      merged_df[paste(col, "diff", sep = "_")] <- NA
    }
    
  }
  
  return(merged_df)
}


SC_diff <- compute_difference(SC22_new, SC23_new, 0.2)


SA_diff <- compute_difference(SA22_new, SA23_new, 0.2)


SP_diff <- compute_difference(SP22_new, SP23_new, 0.2)


SK_diff <- compute_difference(SK22_new, SK23_new, 0.2)


colnames(SC_diff) <- gsub("\\.x$", "_2022", colnames(SC_diff))
colnames(SC_diff) <- gsub("\\.y$", "_2023", colnames(SC_diff))

colnames(SA_diff) <- gsub("\\.x$", "_2022", colnames(SA_diff))
colnames(SA_diff) <- gsub("\\.y$", "_2023", colnames(SA_diff))

colnames(SP_diff) <- gsub("\\.x$", "_2022", colnames(SP_diff))
colnames(SP_diff) <- gsub("\\.y$", "_2023", colnames(SP_diff))

colnames(SK_diff) <- gsub("\\.x$", "_2022", colnames(SK_diff))
colnames(SK_diff) <- gsub("\\.y$", "_2023", colnames(SK_diff))


new_order <- c("MCO", 
               "Service.Area", 
               "Plan.Code", 
               "Measurement",
               "Denominator_2022", 
               "Denominator_2023", 
               "Denominator_diff", 
               "Denominator_sig", 
               "Score_2022", 
               "Score_2023", 
               "Score_diff", 
               "Score_sig", 
               "Nearest.Cluster.Center_2022", 
               "Nearest.Cluster.Center_2023", 
               "Nearest.Cluster.Center_diff", 
               "Nearest.Cluster.Center_sig", 
               "Component.Rating_2022", 
               "Component.Rating_2023", 
               "Component.Rating_diff", 
               "Component.Rating_sig", 
               "Reliability_2022", 
               "Reliability_2023", 
               "Reliability_diff", 
               "Reliability_sig", 
               "Composite.score_2022",
               "Composite.score_2023",
               "Composite.score_diff",
               "Composite.score_sig",
               "Final.Rating_2022", 
               "Final.Rating_2023", 
               "Final.Rating_diff", 
               "Final.Rating_sig"
               )

SA_diff <- SA_diff[, new_order]
SC_diff <- SC_diff[, new_order]
SP_diff <- SP_diff[, new_order]
SK_diff <- SK_diff[, new_order]

RPC2023 <- rbind(SA_diff, SC_diff, SP_diff, SK_diff)
write.xlsx(RPC2023, "C:\\Users\\jiang.shao\\Dropbox (UFL)\\MCO Report Card - 2024\\Program\\2. Admin\\Output\\comparison_2223.xlsx", sheetName = "Sheet1", row.names = FALSE)
