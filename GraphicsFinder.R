
library(tidyverse)
library(fs)


## Latex root directory with .csv 
csv_dir <- "c:/Chris/UN-ESCAP/MyCourses2025/TAPOS25/Slides/"
csv_name <- "Latex_HowToLie_graphics_files.csv"

# Full path for csv with files to search
csv_path <- paste0(csv_dir,csv_name)

# List of folders to search
search_dirs <- c("c:/Chris/Visualisation/Presentations/Graphics",
                 "c:/Chris/Visualisation/Presentations/Graphics/Lies",
                 "c:/Chris/Visualisation/Presentations/Graphics/Logos"
                 )


# Destination folder where matching files should be copied
destination_folder <- "c:/Chris/UN-ESCAP/MyCourses2025/TAPOS25/Slides/Graphics"

# Create destination folder if it doesn't exist
if (!dir_exists(destination_folder)) {
  dir_create(destination_folder)
}

# Read the CSV file 
file_list <- read_csv(csv_path, col_names = FALSE) %>%
  pull(1) %>% # Assuming filenames are in the first column
  str_trim()   # Remove leading/trailing spaces

## Search through directories
search_results <- map(file_list, function(file_name) {
  possible_paths <- path(search_dirs, file_name)
  existing_path <- possible_paths[file_exists(possible_paths)]
  # Collect both found and not found files
  if (length(existing_path) > 0) { 
    tibble(FileName = file_name, FullPath = existing_path[1], Found = TRUE)
  } else {
    tibble(FileName = file_name, FullPath = NA_character_, Found = FALSE)
  }
}) %>%
  bind_rows()

# Extract found files
found_files <- search_results %>%
  filter(Found) %>%
  pull(FullPath)

# Extract not found files
not_found_files <- search_results %>%
  filter(!Found) %>%
  pull(FileName)


# Copy files !!!!
file_copy(found_files, path(destination_folder, path_file(found_files)), overwrite = TRUE)

# Summary
cat(" ____")
cat( "✅ Copied", length(found_files), "files (over ",length(file_list), ") to", destination_folder)
  
  if (length(not_found_files) > 0) {
  cat("❌ The following", length(not_found_files), "files were not found:\n")
  cat(paste("-", not_found_files), sep = "\n")
} else {
  cat("🎉 All files were found in the search directories and copied!\n")
}

# Save results including missing files
write_csv(tibble(search_results), paste0(csv_dir,"Results-", csv_name))




