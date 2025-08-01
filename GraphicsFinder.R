# Finds graphic file is specific directories from  CSV
# Input: A CSV with the list of all files in LaTeX
#       List of directories where to search
# Output: Csv with list  all files and their location
#         txt with list of directories where the files are for inclusion in LaTeX 
# Option to Copy Grpahics: If TRUE all found graphics are copied! 

library(tidyverse)
library(fs)


## Latex root directory with .csv (from InLaTexGraphicFinder.R)
main_dir <- "c:/Chris/UN-ESCAP/MyCourses2025/MLOS25/Slides/"
latex_name <- "LectureWebinar1"

# Csv INPUT with all graphics names
csv_name <-paste0("AllGraphics-", latex_name,".csv")
 
# Full path for csv with files to search
csv_path <- paste0(main_dir,csv_name)

# List of folders to search
search_dirs <- c("c:/Chris/Visualisation/Presentations/Graphics",
                 "c:/Gitmain/MLCourse/UNML",
                 "c:/Chris/UN-ESCAP"
)

# Depth of search 
MyDepth <- 4

# Option to Copy graphics

CopyGraphics <- FALSE

if(CopyGraphics) {
  # Destination folder where matching Graphics should be copied
  destination_folder <-  paste0(main_dir,"Graphics")

  # Create destination folder if it doesn't exist
  if (!dir_exists(destination_folder)) {
    dir_create(destination_folder)
}

}  
# Read the CSV file 
file_list <- read_csv(csv_path, col_names = FALSE) %>%
  pull(1) %>% # Assuming filenames are in the first column
  str_trim()   # Remove leading/trailing spaces



# 🔄 Gather all files from subfolders (max depth = 2)
all_files <- map(search_dirs, ~ dir_ls(.x, recurse = TRUE, type = "file", depth = MyDepth)) %>%
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


### List of unique folder paths from found results

unique_folders <- search_results %>%
  filter(Found) %>%
  distinct(FoundInFolder) %>%
  pull(FoundInFolder)

# Format as {path} for LaTeX inclusion
formatted_paths <- paste0("{", unique_folders, "/}")

# Save to text file
write_lines(formatted_paths, paste0(main_dir,"ListGraphicsFolders.txt"))

# 🖨️ Console confirmation
cat("📄 Unique folders saved to:",main_dir, "\n")

# Extract found files
found_files <- search_results %>%
  filter(Found) %>%
  pull(Requested)

# Extract not found files
not_found_files <- search_results %>%
  filter(!Found) %>%
  pull(Requested)

NbNotFound <- length(not_found_files)
  
if (length(not_found_files) > 0) {
  cat("The following", NbNotFound , "files were not found:\n")
  cat(paste("-", not_found_files), sep = "\n")
} else {
  cat("🎉 All files were found in the search directories and copied!\n")
}

# Save results including missing files
write_csv(tibble(search_results), paste0(main_dir,"AllFiles- NotFound-",NbNotFound,"-",latex_name, ".csv"))

###  Option if copy Graphics is TRUE
if(CopyGraphics) {
  
  # Copy files
  walk2(
    file.path(search_results$FoundInFolder, search_results$Requested),  # source
    file.path(destination_folder, search_results$Requested),            # destination
    file_copy,
    overwrite = TRUE
  )
  
  cat(" ____")
  # cat( "✅ Copied", length(found_files), "files (over ",length(file_list), ") to", destination_folder)
}
