# Finds graphics names in a LaTeX paper
# Output is a .csv file with all graphics used 
# --> Serve as output to:
# - DirFinder.R  (exports the list of dirs where the graphics are)
# - GraphicFinder (copies graphics to a specific location)

library(tidyverse)
library(stringi)

## Latex root directory with .csv 
main_dir <- "c:/Chris/UN-ESCAP/MyCourses2025/MLOS25/Slides/"
latex_name <- "LectureWebinar1"

# Path to sourceLaTeX file
latex_file <-  paste0(main_dir,latex_name,".tex")

# 📤 Destination CSV output
output_csv <- paste0(main_dir,"AllGraphics-", latex_name,".csv")


# 🧪 Read the LaTeX file line by line
lines <- read_lines(latex_file)
latex_text <- paste(lines, collapse = "\n")

# 🔍 Extract all lines that contain \includegraphics
graphics_lines <- lines[str_detect(lines, "\\\\includegraphics")]

# ✅ Regex pattern to match \includegraphics with optional arguments
# Correct pattern (fully escaped)
pattern <- "\\\\includegraphics(?:\\[[^\\]]*\\])?\\{([^}]*)\\}"

# 🔍 Extract file names
matches <- str_match_all(latex_text, pattern)[[1]]
graphic_names <- matches[,2]


# 🧹 Clean and save
graphics_df <- tibble(FileName = graphic_names) %>%
  distinct() %>%
  filter(!is.na(FileName))

# 💾 Write to CSV
write_csv(graphics_df, output_csv, col_names = FALSE)

# ✅ Summary
cat("📄 Found", nrow(graphics_df), "graphics used in LaTeX.\n Saved to:", main_dir, "\n")
