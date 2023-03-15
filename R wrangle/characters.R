# dealing with special characters

# Site
# correct special characters in the site variable and trim whitespace
df$Site <- iconv(df$Site, from = 'UTF-8', to = 'ASCII//TRANSLIT') #to covert special characters
df$Site <- if_else(df$Site == "Â ICDDRb", "ICDDRb", df$Site) #remove special character
df$Site <- trimws(df$Site, which = "both")


# Modify cities to title-case
df$City <- stringr::str_to_title(as.character(df$City))


# modify all to lower case
df$Sample_type <- tolower(df$Sample_type)


# Sample ID: look for spaces " " rather than "_"
check_SampleID <- df %>% 
  filter(stringr::str_detect(SampleID, " "))


