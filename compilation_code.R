
library(here)
library(dplyr)
library(openxlsx)

all_files <- list.files(here::here("raw_data"))

compiled_dataset <- data.frame()

for(file_i in all_files){
  
  data <- read.csv(here::here("raw_data", file_i), skip = 15)
  compiled_dataset <- rbind(compiled_dataset, data)
  
}

compiled_dataset <- compiled_dataset %>%
  dplyr::mutate_at(vars(Year, TotalSpecimenIsolates, InterpretableAST,
                 Resistant, PercentResistant), as.numeric)

write.csv(compiled_dataset, "compiled_WHO_GLASS_2022.csv", row.names = F)
openxlsx::write.xlsx(compiled_dataset, "compiled_WHO_GLASS_2022.xlsx")
