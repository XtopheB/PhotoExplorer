# Finds graphics names and location in a LaTeX paper

# INPUT: Paths and file name to screen 
# Output is a .csv file with all graphics used 
# --> Serve as output to:
# - DirFinder.R  (exports the list of dirs where the graphics are)
# - GraphicFinder (copies graphics to a specific location)

library(tidyverse)
library(stringi)
library(fs)


## Latex root directory 
main_dir <- "c:/Chris/UN-ESCAP/MyCourses2026/DataScienceForOS-Bhutan/Slides/"  # Must end with "/"
# latex_name <- "IAOS-HowToLieWithGraphics"   # Without ".tex"

# Destination CSV output
output_csv <- paste0(main_dir,"AllGraphics.csv")


# Find all .tex files in the main directory
tex_files <- list.files(main_dir, pattern = "\\.tex$", full.names = TRUE)


# Function to extract graphics from a single LaTeX file
extract_graphics <- function(latex_file) {
  # Read the LaTeX file line by line
  lines <- read_lines(latex_file)
  latex_text <- paste(lines, collapse = "\n")
  
  # Regex pattern to match \includegraphics with optional arguments
  pattern <- "\\\\includegraphics(?:\\[[^\\]]*\\])?\\{([^}]*)\\}"
  
  # Extract file names
  matches <- str_match_all(latex_text, pattern)[[1]]
  
  if (nrow(matches) > 0) {
    graphic_names <- matches[, 2]
    return(graphic_names)
  } else {
    return(character(0))
  }
}

#  Extract graphics from all .tex files 
all_graphics <- tex_files %>%
  map(extract_graphics) %>%
  flatten_chr()

# Clean and save
graphics_df <- tibble(FileName = all_graphics) %>%
  distinct() %>%
  filter(!is.na(FileName))

# Write to CSV
write_csv(graphics_df, output_csv, col_names = FALSE)

cat("Processed", length(tex_files), ".tex files\n")
cat("Found", nrow(graphics_df), "unique graphics\n")
cat("Results saved to:", output_csv, "\n")




