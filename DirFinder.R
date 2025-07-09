# Searching for files in sub directories 
# Returning list of directories where the files are used
# Output can be directly used in Latex

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

# Initializing
missing_file_log <- file.path(destination_folder, "files_not_found.csv")
search_log <- file.path(destination_folder, "files_found.csv")


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

# 📥 Copy files that were found
found_files <- search_results %>% filter(Found)
file_copy(found_files$MatchPath, path(destination_folder, path_file(found_files$MatchPath)), overwrite = TRUE)

# 📝 Save logs
write_csv(search_results, search_log)
write_csv(search_results %>% filter(!Found) %>% select(Requested), missing_file_log)

# 🖨️ Console Summary
cat("✅ Copied", nrow(found_files), "files.\n")
cat("📂 Search log saved to:", search_log, "\n")
cat("❌", sum(!search_results$Found), "files not found. Logged at:", missing_file_log, "\n")

# 🖥️ Optional: Show where files were found
if (nrow(found_files) > 0) {
  cat("\n📁 Found file locations:\n")
  print(found_files %>% select(Requested, FoundInFolder))
}

# Extract unique folder paths from found results
unique_folders <- search_results %>%
  filter(Found) %>%
  distinct(FoundInFolder) %>%
  pull(FoundInFolder)

# Format as {path}
formatted_paths <- paste0("{", unique_folders, "/}")

# Output file path
folder_log <- file.path(destination_folder, "Graphicsfolders.txt")

# Save to text file
write_lines(formatted_paths, folder_log)

# 🖨️ Console confirmation
cat("📄 Unique folders saved to:", folder_log, "\n")













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




