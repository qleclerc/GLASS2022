
# This script combines the 2019 GLASS data presented as supplement of the 2021 GLASS report
#  with the publicly available data from the shinyapp provided with the 2022 GLASS report.
# Briefly, the shinyapp contains greater temporal coverage, but some countries are missing.
#  Combining with the 2019 data allows some gaps to be filled.

library(here)
library(dplyr)
library(openxlsx)
library(AMR)

all_files <- list.files(here::here("raw_data"))

compiled_dataset <- data.frame()

for(file_i in all_files){
  
  if(file_i %in%  c("GLASS_2019.xlsx", "who-regions.csv")) next
  
  data <- read.csv(here::here("raw_data", file_i), skip = 15)
  compiled_dataset <- rbind(compiled_dataset, data)
  
}

compiled_dataset <- compiled_dataset %>%
  dplyr::mutate_at(vars(Year, TotalSpecimenIsolates, InterpretableAST,
                        Resistant, PercentResistant), as.numeric)

compiled_dataset <- compiled_dataset %>%
  mutate(PathogenName = mo_name(as.mo(PathogenName))) %>%
  mutate(AbTargets = ab_name(as.ab(AbTargets)))

# WHO regions to align countries between datasets
WHO_regions = read.csv(here("raw_data", "who-regions.csv")) %>%
  select(-Year) %>%
  rbind(data.frame(Entity = c("Kosovo", "Palestine"),
                   Code = c("KOS", "PSE"),
                   WHO.region = c("Europe", "Eastern Mediterranean")))

# Spreadsheet included with 2021 GLASS report (2019 data only)
df_GLASS19 = openxlsx::read.xlsx(here("raw_data", "GLASS_2019.xlsx"))

df_GLASS19 = df_GLASS19 %>%
  select(`country.(ISO-code)`, year, specimen, pathogen, antibiotic_label,
         `Number.of.patients.with.bacterial.growth.(for.a.specific.pathogen)`,
         `Number.of.patients.screened.for.resistance.(for.a.specific.antibiotic)`,
         `Number.of.patients.with.resistant.results.(for.a.specific.antibiotic)`)
colnames(df_GLASS19) = c("Code", "Year", "Specimen", "PathogenName", "AbTargets",
                         "TotalSpecimenIsolates", "InterpretableAST", "Resistant")

df_GLASS19 = df_GLASS19 %>%
  mutate(PercentResistant = Resistant/InterpretableAST*100) %>%
  left_join(WHO_regions, by = "Code") %>%
  rename(Iso3 = Code, CountryTerritoryArea = Entity, WHORegionName = WHO.region) %>%
  select(colnames(compiled_dataset)) %>%
  mutate(WHORegionName = replace(WHORegionName, grepl("Africa", WHORegionName), "African Region"),
         WHORegionName = replace(WHORegionName, grepl("Americas", WHORegionName), "Region of the Americas"),
         WHORegionName = replace(WHORegionName, grepl("Eastern Mediterranean", WHORegionName), "Eastern Mediterranean Region"),
         WHORegionName = replace(WHORegionName, grepl("Europe", WHORegionName), "European Region"),
         WHORegionName = replace(WHORegionName, grepl("South-East Asia", WHORegionName), "South-East Asia Region"),
         WHORegionName = replace(WHORegionName, grepl("Western Pacific", WHORegionName), "Western Pacific Region")) %>%
  mutate(CountryTerritoryArea = replace(CountryTerritoryArea, grepl("Korea", CountryTerritoryArea), "Republic of Korea"),
         CountryTerritoryArea = replace(CountryTerritoryArea, grepl("Russia", CountryTerritoryArea), "Russian Federation"),
         CountryTerritoryArea = replace(CountryTerritoryArea, grepl("Laos", CountryTerritoryArea), "Lao People's Democratic Republic"),
         CountryTerritoryArea = replace(CountryTerritoryArea, grepl("United Kingdom", CountryTerritoryArea), "United Kingdom of Great Britain and Northern Ireland"),
         CountryTerritoryArea = replace(CountryTerritoryArea, grepl("Iran", CountryTerritoryArea), "Iran (Islamic Republic of)")) %>%
  mutate(PathogenName = mo_name(as.mo(PathogenName))) %>%
  mutate(AbTargets = ab_name(as.ab(AbTargets)))

# In the spreadsheet, countries are sometimes split between two lines
# A summarise step to get single estimate for country-year-source-bac-abx is therefore required
df_GLASS19 = df_GLASS19 %>%
  group_by(Iso3, CountryTerritoryArea, WHORegionName, Year, Specimen, PathogenName, AbTargets) %>%
  summarise(TotalSpecimenIsolates = sum(TotalSpecimenIsolates),
            InterpretableAST = sum(InterpretableAST),
            Resistant = sum(Resistant)) %>%
  ungroup %>%
  mutate(PercentResistant = Resistant/InterpretableAST*100)

correct_tot_isolates = df_GLASS19 %>%
  group_by(CountryTerritoryArea, Year, Specimen, PathogenName) %>%
  summarise(TotalSpecimenIsolates = max(TotalSpecimenIsolates)) %>%
  group_by(CountryTerritoryArea, Year, Specimen) %>%
  summarise(TotalSpecimenIsolates = sum(TotalSpecimenIsolates)) %>%
  ungroup

df_GLASS19 = df_GLASS19 %>%
  select(-TotalSpecimenIsolates) %>%
  left_join(correct_tot_isolates, by = c("CountryTerritoryArea", "Year", "Specimen")) %>% 
  select(colnames(compiled_dataset))


# Final combined dataset
compiled_dataset <- rbind(compiled_dataset, df_GLASS19) %>%
  distinct() %>%
  group_by(Iso3, CountryTerritoryArea, WHORegionName, Year, Specimen, PathogenName, AbTargets) %>%
  summarise(across(TotalSpecimenIsolates:PercentResistant, max)) %>%
  ungroup


# Save dataset
write.csv(compiled_dataset, "compiled_WHO_GLASS_2022.csv", row.names = F)
openxlsx::write.xlsx(compiled_dataset, "compiled_WHO_GLASS_2022.xlsx")
