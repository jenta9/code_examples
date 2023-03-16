#load libraries
library(tidyverse)
library(readxl)
library(seqinr)
library(stringr)
# library(purrr)
# library(stringr)
library(Biostrings)
# library(DECIPHER)
# library(ape)

setwd()

########  The import files  ##### 
# load fasta files to modify
rename_seqs <-  seqinr::read.fasta("file1.fas",
                                   as.string = TRUE)

# import the excel file with the key
key_doc <-  read_excel("Renaming_key.xlsx",
                       sheet = "Sheet2",
                       .name_repair = "universal")


####### format for renaming ####
# start with fasta file
names(rename_seqs) # check the sequence names
# separate ref seqs from sequences to rename
ref_seqs <- rename_seqs[231:262]
# keep only the sequences to rename
rename_seqs <- rename_seqs[1:230]


# let's keep only the DASH numbers in the sequence names
# convert to dataframe
library("Biostrings")
fastaFile <- readDNAStringSet("file2.fas")
ref_seqs <- fastaFile[231:262]
fastaFile <- fastaFile[1:230]
seq_name = names(fastaFile)
sequence = paste(fastaFile)
df <- data.frame(seq_name, sequence)

# parse just the DASH number from the name and select
rename_seqs_df <- df %>% 
  mutate(CDC_DASH_Number = gsub("\\_.*", "", seq_name)) %>%
  select(CDC_DASH_Number, sequence)


# now create the names we want to rename with from the excel file
# example of what the final name should look like: Missaukee001_2020

# add new columns parsing out the elements needed and then combining
key_doc <- key_doc %>%
  mutate(
    key_parse_last_4 = str_sub(VG.Specimen.Key, 
                               start= -4),
    new_name = paste0(Location, key_parse_last_4, "_", Year)
  ) %>%
# then select only the two elements needed
  select(CDC_DASH_Number, new_name)

#new names have spaces, so let's replace with an underscore
key_doc$new_name <- gsub(" ", "", key_doc$new_name)


key_doc$CDC_DASH_Number <- as.character(key_doc$CDC_DASH_Number)
#### merge the sequence and rename key in a df
rename_seqs_df <- rename_seqs_df %>%
  left_join(key_doc, by = "CDC_DASH_Number") %>%
  select(new_name, sequence)



#### Convert to FASTA format and export
write_to_fasta <-function(data, filename){
  fastaLines = c()
  for (rowNum in 1:nrow(data)){
    fastaLines = c(fastaLines, as.character(paste(">", data[rowNum,"new_name"], sep = "")))
    fastaLines = c(fastaLines,as.character(data[rowNum,"sequence"]))
  }
  fileConn<-file(filename)
  writeLines(fastaLines, fileConn)
  close(fileConn)
}
#use of function to save fastafile
write_to_fasta(rename_seqs_df, 
               "file_export.fas")


key_doc_list <- key_doc %>%
  filter(new_name %in% rename_seqs_df$new_name)

write_csv(key_doc_list, "key.csv")

