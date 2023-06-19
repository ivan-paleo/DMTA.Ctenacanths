Import dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-06-19 15:18:59 CEST

- [Goal of the script](#goal-of-the-script)
- [Load packages](#load-packages)
- [Get names and path all files](#get-names-and-path-all-files)
- [Read and format data](#read-and-format-data)
  - [Read in CSV file](#read-in-csv-file)
  - [Select relevant columns and
    rows](#select-relevant-columns-and-rows)
  - [Add headers](#add-headers)
  - [Extract units](#extract-units)
  - [Split column ‘Name’](#split-column-name)
  - [Convert to numeric](#convert-to-numeric)
  - [Add column for NMP categories](#add-column-for-nmp-categories)
  - [Re-order columns and add units as
    comment](#re-order-columns-and-add-units-as-comment)
  - [Check the result](#check-the-result)
- [Save data](#save-data)
  - [Create file names](#create-file-names)
  - [Write to XLSX and Rbin](#write-to-xlsx-and-rbin)
- [sessionInfo()](#sessioninfo)
- [Cite R packages used](#cite-r-packages-used)
  - [References](#references)

------------------------------------------------------------------------

# Goal of the script

This script formats the output of the resulting files from applying
surface texture analysis to a sample of Devonian shark teeth. The script
will:

1.  Read in the original files  
2.  Format the data  
3.  Write XLSX-files and save R objects ready for further analysis in R

``` r
dir_out <- "derived_data"
dir_in  <- "raw_data"
```

Raw data must be located in “~/raw_data”.  
Formatted data will be saved in “~/derived_data”.

The knit directory for this script is the project directory.

------------------------------------------------------------------------

# Load packages

``` r
pack_to_load <- c("grateful", "knitr", "openxlsx", "R.utils", "rmarkdown", "tidyverse")
sapply(pack_to_load, library, character.only = TRUE, logical.return = TRUE) 
```

     grateful     knitr  openxlsx   R.utils rmarkdown tidyverse 
         TRUE      TRUE      TRUE      TRUE      TRUE      TRUE 

------------------------------------------------------------------------

# Get names and path all files

``` r
info_in <- list.files(dir_in, pattern = "\\.csv$", full.names = TRUE)
info_in
```

    [1] "raw_data/DMTAsharks_EAVP_processing_100x.csv"

------------------------------------------------------------------------

# Read and format data

## Read in CSV file

``` r
sharks <- read.csv(info_in, header = FALSE, na.strings = "*****", fileEncoding = 'WINDOWS-1252')
```

## Select relevant columns and rows

``` r
sharks_keep_col  <- c(4, 26, 57:58, 61:63)                    # Define columns to keep
sharks_keep_rows <- which(sharks[[1]] != "#")                 # Define rows to keep
sharks_keep      <- sharks[sharks_keep_rows, sharks_keep_col] # Subset rows and columns
```

## Add headers

``` r
# Get headers from 2nd row
colnames(sharks_keep) <- sharks[2, sharks_keep_col] %>% 
  
                         # Convert to valid names
                         make.names() %>% 
  
                         # Delete repeated periods
                         gsub("\\.+", "\\.", x = .) %>% 
  
                         # Delete periods at the end of the names
                         gsub("\\.$", "", x = .) %>%
  
                         # Keep only part after the last period
                         gsub("^([A-Za-z0-9]+\\.)+", "", x = .)

# Edit name for NMP
colnames(sharks_keep)[2] <- "NMP"
```

## Extract units

``` r
# Extract unit line for considered columns
sharks_units <- unlist(sharks[3, sharks_keep_col[-1]])

# Get names associated to the units
names(sharks_units) <- colnames(sharks_keep)[-1]

# Combine into a data.frame for export
units_table <- data.frame(variable = names(sharks_units), units = sharks_units)
```

## Split column ‘Name’

``` r
sharks_keep[c("Specimen", "Tooth", "Location", "Objective", "Measurement")] <- str_split_fixed(sharks_keep$Name, 
                                                                                               "_", n = 5)
```

## Convert to numeric

``` r
sharks_keep <- type_convert(sharks_keep)
```

## Add column for NMP categories

Here we define 3 ranges of non-measured points (NMP):

- $<$ 10% NMP: “\<10%”  
- $\ge$ 10% and $<$ 20% NMP: “10-20%”  
- $\ge$ 20% NMP: “≥20%”

``` r
# Create new column and fill it
sharks_keep[sharks_keep$NMP < 10                        , "NMP_cat"] <- "<10%"
sharks_keep[sharks_keep$NMP >= 10 & sharks_keep$NMP < 20, "NMP_cat"] <- "10-20%"
sharks_keep[sharks_keep$NMP >= 20                       , "NMP_cat"] <- "≥20%"

# Convert to ordered factor
sharks_keep[["NMP_cat"]] <- factor(sharks_keep[["NMP_cat"]], levels = c("<10%", "10-20%", "≥20%"), ordered = TRUE)
```

## Re-order columns and add units as comment

``` r
sharks_final <- select(sharks_keep, Specimen:Measurement, NMP_cat, NMP:HAsfc9)
comment(sharks_final) <- sharks_units
```

Type `comment(sharks_final)` to check the units of the parameters.

## Check the result

``` r
str(sharks_final)
```

    'data.frame':   80 obs. of  12 variables:
     $ Specimen   : chr  "CC" "CC" "CC" "CC" ...
     $ Tooth      : chr  "A" "A" "A" "A" ...
     $ Location   : chr  "loc1" "loc1" "loc1" "loc2" ...
     $ Objective  : chr  "100x" "100x" "100x" "100x" ...
     $ Measurement: chr  "meas1" "meas2" "meas3" "meas1" ...
     $ NMP_cat    : Ord.factor w/ 3 levels "<10%"<"10-20%"<..: 1 1 1 1 1 1 2 2 2 1 ...
     $ NMP        : num  3.03 3.05 3.34 9.84 9.78 ...
     $ epLsar     : num  0.00119 0.00113 0.00124 0.00152 0.0018 ...
     $ NewEplsar  : num  0.0172 0.0172 0.0173 0.0176 0.0177 ...
     $ Asfc       : num  1.85 1.79 1.82 9.4 7.54 ...
     $ Smfc       : num  86.2 48.8 52 37.9 62.8 ...
     $ HAsfc9     : num  0.249 0.233 0.172 3.11 1.59 ...
     - attr(*, "comment")= Named chr [1:6] "%" "<no unit>" "<no unit>" "<no unit>" ...
      ..- attr(*, "names")= chr [1:6] "NMP" "epLsar" "NewEplsar" "Asfc" ...

``` r
head(sharks_final)
```

      Specimen Tooth Location Objective Measurement NMP_cat      NMP      epLsar
    4       CC     A     loc1      100x       meas1    <10% 3.029439 0.001190735
    5       CC     A     loc1      100x       meas2    <10% 3.049307 0.001128928
    6       CC     A     loc1      100x       meas3    <10% 3.344563 0.001244379
    7       CC     A     loc2      100x       meas1    <10% 9.838464 0.001522344
    8       CC     A     loc2      100x       meas2    <10% 9.778688 0.001796346
    9       CC     A     loc2      100x       meas3    <10% 9.676411 0.001234300
       NewEplsar     Asfc     Smfc    HAsfc9
    4 0.01718885 1.851713 86.15295 0.2487842
    5 0.01723834 1.787470 48.78199 0.2329559
    6 0.01734807 1.822078 51.96430 0.1722548
    7 0.01759510 9.401217 37.88585 3.1102284
    8 0.01773082 7.539994 62.81191 1.5898377
    9 0.01778692 7.913469 51.96430 1.2035583

------------------------------------------------------------------------

# Save data

## Create file names

``` r
sharks_xlsx <- paste0(dir_out, "/DMTAsharks_EAVP_100x.xlsx")
sharks_rbin <- paste0(dir_out, "/DMTAsharks_EAVP_100x.Rbin")
```

## Write to XLSX and Rbin

``` r
write.xlsx(list(data = sharks_final, units = units_table), file = sharks_xlsx) 
saveObject(sharks_final, file = sharks_rbin) 
```

Rbin files (e.g. `DMTAsharks_EAVP_100x.Rbin`) can be easily read into an
R object (e.g. `rbin_data`) using the following code:

``` r
library(R.utils)
rbin_data <- loadObject("DMTAsharks_EAVP_100x.Rbin")
```

------------------------------------------------------------------------

# sessionInfo()

``` r
sessionInfo()
```

    R version 4.3.1 (2023-06-16 ucrt)
    Platform: x86_64-w64-mingw32/x64 (64-bit)
    Running under: Windows 10 x64 (build 19043)

    Matrix products: default


    locale:
    [1] LC_COLLATE=English_United States.utf8 
    [2] LC_CTYPE=English_United States.utf8   
    [3] LC_MONETARY=English_United States.utf8
    [4] LC_NUMERIC=C                          
    [5] LC_TIME=English_United States.utf8    

    time zone: Europe/Berlin
    tzcode source: internal

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] lubridate_1.9.2   forcats_1.0.0     stringr_1.5.0     dplyr_1.1.2      
     [5] purrr_1.0.1       readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
     [9] ggplot2_3.4.2     tidyverse_2.0.0   rmarkdown_2.22    R.utils_2.12.2   
    [13] R.oo_1.25.0       R.methodsS3_1.8.2 openxlsx_4.2.5.2  knitr_1.43       
    [17] grateful_0.2.0   

    loaded via a namespace (and not attached):
     [1] sass_0.4.6       utf8_1.2.3       generics_0.1.3   stringi_1.7.12  
     [5] hms_1.1.3        digest_0.6.31    magrittr_2.0.3   timechange_0.2.0
     [9] evaluate_0.21    grid_4.3.1       fastmap_1.1.1    rprojroot_2.0.3 
    [13] jsonlite_1.8.5   zip_2.3.0        fansi_1.0.4      scales_1.2.1    
    [17] jquerylib_0.1.4  cli_3.6.1        crayon_1.5.2     rlang_1.1.1     
    [21] munsell_0.5.0    withr_2.5.0      cachem_1.0.8     yaml_2.3.7      
    [25] tools_4.3.1      tzdb_0.4.0       colorspace_2.1-0 vctrs_0.6.3     
    [29] R6_2.5.1         lifecycle_1.0.3  pkgconfig_2.0.3  pillar_1.9.0    
    [33] bslib_0.5.0      gtable_0.3.3     glue_1.6.2       Rcpp_1.0.10     
    [37] xfun_0.39        tidyselect_1.2.0 rstudioapi_0.14  htmltools_0.5.5 
    [41] compiler_4.3.1  

------------------------------------------------------------------------

# Cite R packages used

We used the following R packages: grateful v. 0.2.0 (Francisco
Rodríguez-Sánchez, Connor P. Jackson, and Shaurita D. Hutchins 2023),
knitr v. 1.43 (Xie 2014, 2015, 2023), openxlsx v. 4.2.5.2 (Schauberger
and Walker 2023), R.utils v. 2.12.2 (Bengtsson 2022), rmarkdown v. 2.22
(Xie, Allaire, and Grolemund 2018; Xie, Dervieux, and Riederer 2020;
Allaire et al. 2023), tidyverse v. 2.0.0 (Wickham et al. 2019), running
in RStudio v. 2023.6.0.421 (Posit team 2023).

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-rmarkdown2023" class="csl-entry">

Allaire, JJ, Yihui Xie, Christophe Dervieux, Jonathan McPherson, Javier
Luraschi, Kevin Ushey, Aron Atkins, et al. 2023.
*<span class="nocase">rmarkdown</span>: Dynamic Documents for r*.
<https://github.com/rstudio/rmarkdown>.

</div>

<div id="ref-Rutils" class="csl-entry">

Bengtsson, Henrik. 2022. *<span class="nocase">R.utils</span>: Various
Programming Utilities*. <https://CRAN.R-project.org/package=R.utils>.

</div>

<div id="ref-grateful" class="csl-entry">

Francisco Rodríguez-Sánchez, Connor P. Jackson, and Shaurita D.
Hutchins. 2023. *<span class="nocase">grateful</span>: Facilitate
Citation of r Packages*. <https://github.com/Pakillo/grateful>.

</div>

<div id="ref-rstudio" class="csl-entry">

Posit team. 2023. *RStudio: Integrated Development Environment for r*.
Boston, MA: Posit Software, PBC. <http://www.posit.co/>.

</div>

<div id="ref-openxlsx" class="csl-entry">

Schauberger, Philipp, and Alexander Walker. 2023.
*<span class="nocase">openxlsx</span>: Read, Write and Edit Xlsx Files*.
<https://CRAN.R-project.org/package=openxlsx>.

</div>

<div id="ref-tidyverse" class="csl-entry">

Wickham, Hadley, Mara Averick, Jennifer Bryan, Winston Chang, Lucy
D’Agostino McGowan, Romain François, Garrett Grolemund, et al. 2019.
“Welcome to the <span class="nocase">tidyverse</span>.” *Journal of Open
Source Software* 4 (43): 1686. <https://doi.org/10.21105/joss.01686>.

</div>

<div id="ref-knitr2014" class="csl-entry">

Xie, Yihui. 2014. “<span class="nocase">knitr</span>: A Comprehensive
Tool for Reproducible Research in R.” In *Implementing Reproducible
Computational Research*, edited by Victoria Stodden, Friedrich Leisch,
and Roger D. Peng. Chapman; Hall/CRC.

</div>

<div id="ref-knitr2015" class="csl-entry">

———. 2015. *Dynamic Documents with R and Knitr*. 2nd ed. Boca Raton,
Florida: Chapman; Hall/CRC. <https://yihui.org/knitr/>.

</div>

<div id="ref-knitr2023" class="csl-entry">

———. 2023. *<span class="nocase">knitr</span>: A General-Purpose Package
for Dynamic Report Generation in r*. <https://yihui.org/knitr/>.

</div>

<div id="ref-rmarkdown2018" class="csl-entry">

Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. *R Markdown: The
Definitive Guide*. Boca Raton, Florida: Chapman; Hall/CRC.
<https://bookdown.org/yihui/rmarkdown>.

</div>

<div id="ref-rmarkdown2020" class="csl-entry">

Xie, Yihui, Christophe Dervieux, and Emily Riederer. 2020. *R Markdown
Cookbook*. Boca Raton, Florida: Chapman; Hall/CRC.
<https://bookdown.org/yihui/rmarkdown-cookbook>.

</div>

</div>
