
library(tidyverse)
library(fs)

# Path to your CSV file containing the list of filenames
csv_path <- "c:/Chris/UN-ESCAP/MyCourses2025/TAPOS25/Slides/Latex_HowToLie_graphics_files.csv"

# Source folder where the files are stored
source_folder <- "c:/Chris/Visualisation/Presentations/Graphics/Lies"

# Destination folder where matching files should be copied
destination_folder <- "C:/Temp/MyGraphics"

# Create destination folder if it doesn't exist
if (!dir_exists(destination_folder)) {
  dir_create(destination_folder)
}

# Read the CSV file into a data frame
file_list <- read_csv(csv_path, col_names = FALSE) %>%
  pull(1) %>% # Assuming filenames are in the first column
  str_trim()   # Remove leading/trailing spaces

# Get full paths of matching files
source_files <- path(source_folder, file_list)
print(source_files)

# Filter out files that don't exist
existing_files <- source_files[file_exists(source_files)]

# Copy them to the destination folder
file_copy(existing_files, path(destination_folder, path_file(existing_files)), overwrite = TRUE)

# Print summary
cat("Copied", length(existing_files), "files to", destination_folder, "\n")
