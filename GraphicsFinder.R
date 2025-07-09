# Finds graphic file is specific directories from  CSV
# Input: A CSV with the list of all files in LaTeX
#       List of directories where to search
# Output: Csv with list  all files and their location
#         txt with list of directories where the files are for inclusion in LaTeX 

library(tidyverse)
library(fs)

## Latex root directory with .csv 
main_dir <- "c:/Chris/UN-ESCAP/MyCourses2025/TAPOS25/Slides/"
latex_name <- "DV-Webinar-How-Not-ToLie"

# Csv INPUT with all graphics names
csv_name <-paste0("AllGraphics-", latex_name,".csv")
 
# Full path for csv with files to search
csv_path <- paste0(main_dir,csv_name)

# List of folders to search
search_dirs <- c("c:/Chris/Visualisation/Presentations/Graphics",
                 "c:/Chris/UN-ESCAP/MyCourses/DataViz/Graphics")


# Destination folder where matching Graphics should be copied
destination_folder <-  paste0(main_dir,"Graphics")

# Create destination folder if it doesn't exist
if (!dir_exists(destination_folder)) {
  dir_create(destination_folder)
}

# Read the CSV file 
file_list <- read_csv(csv_path, col_names = FALSE) %>%
  pull(1) %>% # Assuming filenames are in the first column
  str_trim()   # Remove leading/trailing spaces

## Search through directories
# search_results <- map(file_list, function(file_name) {
#   possible_paths <- path(search_dirs, file_name)
#   existing_path <- possible_paths[file_exists(possible_paths)]
#   # Collect both found and not found files
#   if (length(existing_path) > 0) { 
#     tibble(FileName = file_name, FullPath = existing_path[1], Found = TRUE)
#   } else {
#     tibble(FileName = file_name, FullPath = NA_character_, Found = FALSE)
#   }
# }) %>%
#   bind_rows()


# 🔄 Gather all files from subfolders (max depth = 2)
all_files <- map(search_dirs, ~ dir_ls(.x, recurse = TRUE, type = "file", depth = 2)) %>%
  flatten_chr()

# 🔍 Match requested files
search_results <- tibble(Requested = file_list) %>%
  mutate(
    MatchPath = map_chr(Requested, function(fname) {
      matched <- all_files[basename(all_files) == fname]
      if (length(matched) > 0) return(matched[1])
      return(NA_character_)
    }),
    Found = !is.na(MatchPath),
    FoundInFolder = if_else(Found, path_dir(MatchPath), NA_character_)
  )


# Extract found files
found_files <- search_results %>%
  filter(Found) %>%
  pull(Requested)

# Extract not found files
not_found_files <- search_results %>%
  filter(!Found) %>%
  pull(Requested)

NbNotFound <- length(not_found_files)


# Summary
cat(" ____")
cat( "✅ Copied", length(found_files), "files (over ",length(file_list), ") to", destination_folder)
  
  if (length(not_found_files) > 0) {
  cat("The following", NbNotFound , "files were not found:\n")
  cat(paste("-", not_found_files), sep = "\n")
} else {
  cat("🎉 All files were found in the search directories and copied!\n")
}

# Save results including missing files
write_csv(tibble(search_results), paste0(main_dir,"AllFiles- NotFound-",NbNotFound,"-",latex_name, ".csv"))




