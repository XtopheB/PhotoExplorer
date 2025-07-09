
library(tidyverse)
library(fs)

# Path to your CSV file containing the list of filenames
csv_path <- "c:/Chris/UN-ESCAP/MyCourses2025/TAPOS25/Slides/Latex_HowToLie_graphics_files.csv"

# Source folder where the files are stored
source_folder <- "c:/Chris/Visualisation/Presentations/Graphics/Lies"

# Multiple directories
# List of folders to search
search_dirs <- c("c:/Chris/Visualisation/Presentations/Graphics",
                 "c:/Chris/Visualisation/Presentations/Graphics/Lies",
                 "c:/Chris/Visualisation/Presentations/Graphics/Logos"
                 )


# Destination folder where matching files should be copied
destination_folder <- "C:/Temp/MyGraphics"

# Create destination folder if it doesn't exist
if (!dir_exists(destination_folder)) {
  dir_create(destination_folder)
}

# Read the CSV file 
file_list <- read_csv(csv_path, col_names = FALSE) %>%
  pull(1) %>% # Assuming filenames are in the first column
  str_trim()   # Remove leading/trailing spaces

# 🔍 Search through directories
found_files <- map_chr(file_list, function(file_name) {
  possible_paths <- path(search_dirs, file_name)
  existing_path <- possible_paths[file_exists(possible_paths)]
  if (length(existing_path) > 0) return(existing_path[1])
  return(NA_character_) # Not found
}) %>%
  discard(is.na)





# Copy files
file_copy(found_files, path(destination_folder, path_file(found_files)), overwrite = TRUE)

# Summary
cat("✅ Copied", length(found_files), "files (over",length(source_files), ") to", destination_folder, "\n")



