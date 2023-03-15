# Importing muliple files or sheets from excel

# mult xlsx ####
# import multiple xlsx files from a single folder and compile into 1 df
# skip the first 7 rows
batch1 <- list.files(path = "path",    
                     pattern = "*.xls",
                     full.names = TRUE) %>% 
  lapply(read_excel, .name_repair = "universal", skip = 7) %>% 
  bind_rows 



# mult csv ####
# import multiple csv files from a single folder # read multiple excel files from a single folder 
# skip 27 rows and select only 5 cols (Var1-Var5)
batch3 <- list.files(path = "path",    
                     pattern = "*.csv",
                     full.names = TRUE) %>% 
  lapply(read_csv, name_repair = "universal", skip = 27, 
         col_select = c(Var1, Var2, Var3, Var4, Var5), 
         show_col_types = FALSE) %>% 
  bind_rows 



# mult sheets #### 
# import multiple columns from a single excel file and compile into 1 df
# indicate the sheet name with "sheet = x" so that info can be kept with the merge of sheets
file1 <- "path.xlsx" # file name

# list sheet names to import containing missing realtime and/or genotyping noro data from yrs 1 and 2
sheet.names.f1 <- c("Sheet1","Sheet2","Sheet3","Sheet4") 

# import data from sheet.names.f1
update <- lapply(sheet.names.f1, 
                       function(x) read_excel(
                         path = file1, 
                         sheet = x,
                         .name_repair = "universal"
                       ))

# bind the sheets (list elements) together into one df
update_comp <- bind_rows(update, .id="Sheet")

