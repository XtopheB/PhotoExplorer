

library(tidyverse)
library(stringi)

## Latex root directory with .csv 
main_dir <- "c:/Chris/UN-ESCAP/MyCourses2025/TAPOS25/Slides/"
latex_name <- "DV-Webinar-How-Not-ToLie"

# Path to LaTeX file
latex_file <-  paste0(main_dir,latex_name,".tex")

# 📤 Destination CSV output
output_csv <- "C:/graphics/graphics_used.csv"

# List of folders to search
search_dirs <- c("c:/Chris/Visualisation/Presentations/Graphics",
                 "c:/Chris/Visualisation/Presentations/Graphics/Lies",
                 "c:/Chris/Visualisation/Presentations/Graphics/Logos"
)


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
write_csv(graphics_df, paste0(main_dir,latex_name,".csv"), col_names = FALSE)

# ✅ Summary
cat("📄 Found", nrow(graphics_df), "graphics used in LaTeX.\nSaved to:", main_dir, "\n")
