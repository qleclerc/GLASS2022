# Compiled data from WHO GLASS 2022 report

*You can directly load the compiled dataset in R, using for example
`read.csv("https://raw.githubusercontent.com/qleclerc/GLASS2022/master/compiled_WHO_GLASS_2022.csv")`
or
`openxlsx::read.xlsx("https://github.com/qleclerc/GLASS2022/blob/master/compiled_WHO_GLASS_2022.xlsx?raw=true")`*

## Summary

The World Health Organization [2022 GLASS report](https://www.who.int/publications/i/item/9789240062702) published in December 2022 presents global data on antimicrobial resistance from 2020.
This data can be freely accessed via the WHO ShinyApp here: https://worldhealthorg.shinyapps.io/glass-dashboard/

Within this app, the plots from the report can all be recreated, and the underlying dataset for each plot can be downloaded.
However, each plot dataset only represents a subset of the complete GLASS dataset. Unfortunately, the complete dataset cannot be
downloaded directly from the app, or scraped automatically from the source code.

In addition, the 2021 GLASS report was accompanied by a spreadsheet containing all data for 2019, publicly accessible.

This repository essentially attempts to "recreate" the entire GLASS dataset by compiling all the subset datasets freely available via the ShinyApp, plus the 2019 data.

**Important**: this is unfortunately not the **complete** GLASS dataset, since part of it is not freely available via the app.
Briefly, this only contains countries which have data for all years between 2017 and 2020, PLUS all data for 2019 (since this uses another spreadsheet provided by WHO).
If a country has missed out on at least one year between 2017-2020 (except 2019), they will not appear in the compiled dataset.

## Repository contents

I manually downloaded all the datasets for 91 bacteria-antibiotic combinations used to generate the "Time series of resistance to
antibacterials (2017-2020)" plots in the app, and included them in the `raw_data` folder here. This folder also contains the 2019
GLASS data (supplement of 2021 report), and a file listing WHO Regions. The script in `compilation_code.R` reads
all these files, and generates the `compiled_WHO_GLASS_2022.csv` and `compiled_WHO_GLASS_2022.xlsx` files.

Complete dataset variables:
- **Iso3**: 3-letters country code
- **CountryTerritoryArea**: complete country, territory, or area (CTA) name
- **WHORegionName**: WHO Region to which the CTA belongs
- **Year**: data year (2017-2020)
- **Specimen**: source of samples (blood, genital, stool, urine)
- **PathogenName**: name of the bacteria species for which resistance is reported
- **AbTargets**: antibiotic for which resistance is reported
- **TotalSpecimenIsolates**: total isolates reported for this combination of year, CTA and specimen (bacteria and antibiotic aggregated!)
- **InterpretableAST**: total isolates with antibiotic susceptibility reported for this combination of year, CTA, specimen, bacteria, and antibiotic
- **Resistant**: total isolates resistant for this combination of year, CTA, specimen, bacteria, and antibiotic
- **PercentResistant**: percent of tested isolates that are resistant (=Resistant/InterpretableAST\*100)

## Disclaimers

Note: WHO is not responsible for the content or accuracy of the code and data in this repository.

Original datasets from:
- Global antimicrobial resistance and use surveillance system (GLASS) report 2022. Geneva: World Health Organization; 2022. Licence: CC BY-NC-SA 3.0 IGO.
- Global antimicrobial resistance and use surveillance system (GLASS) report 2021. Geneva: World Health Organization; 2021. Licence: CC BY-NC-SA 3.0 IGO.

Code and compiled dataset by: Quentin Leclerc (quentin.leclerc@lecnam.net; https://bsky.app/profile/quentinlclrc.bsky.social)

If you wish to acknowledge this repository as the source of the compiled dataset, please cite as: Leclerc, Q.J. (2022). Compiled data from WHO GLASS 2022 report (Version 2.0) [GitHub Repository]. https://doi.org/10.5281/zenodo.7486150

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 IGO License](https://creativecommons.org/licenses/by-nc-sa/3.0/igo/).
The published material is being distributed without warranty of any kind, either expressed or implied. The
responsibility for the interpretation and use of the material lies exclusively with the reader.
