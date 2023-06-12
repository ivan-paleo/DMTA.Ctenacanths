Import dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-06-12 17:22:17

- <a href="#goal-of-the-script" id="toc-goal-of-the-script">Goal of the
  script</a>
- <a href="#load-packages" id="toc-load-packages">Load packages</a>
- <a href="#get-names-and-path-all-files"
  id="toc-get-names-and-path-all-files">Get names and path all files</a>
- <a href="#read-and-format-data" id="toc-read-and-format-data">Read and
  format data</a>
  - <a href="#read-in-csv-file" id="toc-read-in-csv-file">Read in CSV
    file</a>
  - <a href="#select-relevant-columns-and-rows"
    id="toc-select-relevant-columns-and-rows">Select relevant columns and
    rows</a>
  - <a href="#add-headers" id="toc-add-headers">Add headers</a>
  - <a href="#extract-units" id="toc-extract-units">Extract units</a>
  - <a href="#split-column-name" id="toc-split-column-name">Split column
    ‘Name’</a>
  - <a href="#convert-to-numeric" id="toc-convert-to-numeric">Convert to
    numeric</a>
  - <a href="#add-column-for-nmp-categories"
    id="toc-add-column-for-nmp-categories">Add column for NMP categories</a>
  - <a href="#re-order-columns-and-add-units-as-comment"
    id="toc-re-order-columns-and-add-units-as-comment">Re-order columns and
    add units as comment</a>
  - <a href="#check-the-result" id="toc-check-the-result">Check the
    result</a>
- <a href="#save-data" id="toc-save-data">Save data</a>
  - <a href="#create-file-names" id="toc-create-file-names">Create file
    names</a>
  - <a href="#write-to-xlsx-and-rbin" id="toc-write-to-xlsx-and-rbin">Write
    to XLSX and Rbin</a>
- <a href="#sessioninfo-and-rstudio-version"
  id="toc-sessioninfo-and-rstudio-version">sessionInfo() and RStudio
  version</a>
- <a href="#cite-r-packages-used" id="toc-cite-r-packages-used">Cite R
  packages used</a>

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

Raw data must be located in “\~/raw_data”.  
Formatted data will be saved in “\~/derived_data”.

The knit directory for this script is the project directory.

------------------------------------------------------------------------

# Load packages

``` r
pack_to_load <- c("openxlsx", "R.utils", "tidyverse")
sapply(pack_to_load, library, character.only = TRUE, logical.return = TRUE) 
```

     openxlsx   R.utils tidyverse 
         TRUE      TRUE      TRUE 

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
sharks_keep_col  <- c(4, 26, 57:58, 61:63) # Define columns to keep
sharks_keep_rows <- which(sharks[[1]] != "#") # Define rows to keep
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
sharks_units <- unlist(sharks[3, sharks_keep_col[-1]])                           # Extract unit line for considered columns
names(sharks_units) <- colnames(sharks_keep)[-1]                                 # Get names associated to the units
units_table <- data.frame(variable = names(sharks_units), units = sharks_units)  # Combine into a data.frame for export
```

## Split column ‘Name’

``` r
sharks_keep[c("Species", "Specimen", "Location", "Objective", "Measurement")] <- str_split_fixed(sharks_keep$Name, "_", n = 5)
```

## Convert to numeric

``` r
sharks_keep <- type_convert(sharks_keep)
```

## Add column for NMP categories

Here we define 3 ranges of non-measured points (NMP):

- $<$ 10% NMP: “0-10%”  
- $\ge$ 10% and $<$ 20% NMP: “10-20%”  
- $\ge$ 20% NMP: “20-100%”

``` r
# Create new column and fill it
sharks_keep[sharks_keep$NMP < 10                        , "NMP_cat"] <- "< 10%"
sharks_keep[sharks_keep$NMP >= 10 & sharks_keep$NMP < 20, "NMP_cat"] <- "10-20%"
sharks_keep[sharks_keep$NMP >= 20                       , "NMP_cat"] <- "≥ 20%"

# Convert to ordered factor
sharks_keep[["NMP_cat"]] <- factor(sharks_keep[["NMP_cat"]], levels = c("< 10%", "10-20%", "≥ 20%"), ordered = TRUE)
```

## Re-order columns and add units as comment

``` r
sharks_final <- select(sharks_keep, Species:Measurement, NMP_cat, NMP:HAsfc9)
comment(sharks_final) <- sharks_units
```

Type `comment(sharks_final)` to check the units of the parameters.

## Check the result

``` r
str(sharks_final)
```

    'data.frame':   80 obs. of  12 variables:
     $ Species    : chr  "CC" "CC" "CC" "CC" ...
     $ Specimen   : chr  "A" "A" "A" "A" ...
     $ Location   : chr  "loc1" "loc1" "loc1" "loc2" ...
     $ Objective  : chr  "100x" "100x" "100x" "100x" ...
     $ Measurement: chr  "meas1" "meas2" "meas3" "meas1" ...
     $ NMP_cat    : Ord.factor w/ 3 levels "< 10%"<"10-20%"<..: 1 1 1 1 1 1 2 2 2 1 ...
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

      Species Specimen Location Objective Measurement NMP_cat      NMP      epLsar
    4      CC        A     loc1      100x       meas1   < 10% 3.029439 0.001190735
    5      CC        A     loc1      100x       meas2   < 10% 3.049307 0.001128928
    6      CC        A     loc1      100x       meas3   < 10% 3.344563 0.001244379
    7      CC        A     loc2      100x       meas1   < 10% 9.838464 0.001522344
    8      CC        A     loc2      100x       meas2   < 10% 9.778688 0.001796346
    9      CC        A     loc2      100x       meas3   < 10% 9.676411 0.001234300
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

# sessionInfo() and RStudio version

``` r
sessionInfo()
```

    R version 4.2.2 (2022-10-31 ucrt)
    Platform: x86_64-w64-mingw32/x64 (64-bit)
    Running under: Windows 10 x64 (build 19043)

    Matrix products: default

    locale:
    [1] LC_COLLATE=English_United States.utf8 
    [2] LC_CTYPE=English_United States.utf8   
    [3] LC_MONETARY=English_United States.utf8
    [4] LC_NUMERIC=C                          
    [5] LC_TIME=English_United States.utf8    

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] lubridate_1.9.2   forcats_1.0.0     stringr_1.5.0     dplyr_1.1.0      
     [5] purrr_1.0.1       readr_2.1.4       tidyr_1.3.0       tibble_3.1.8     
     [9] ggplot2_3.4.1     tidyverse_2.0.0   R.utils_2.12.2    R.oo_1.25.0      
    [13] R.methodsS3_1.8.2 openxlsx_4.2.5.2 

    loaded via a namespace (and not attached):
     [1] tidyselect_1.2.0 xfun_0.37        bslib_0.4.2      colorspace_2.1-0
     [5] vctrs_0.5.2      generics_0.1.3   htmltools_0.5.4  yaml_2.3.7      
     [9] utf8_1.2.3       rlang_1.0.6      jquerylib_0.1.4  pillar_1.8.1    
    [13] glue_1.6.2       withr_2.5.0      lifecycle_1.0.3  munsell_0.5.0   
    [17] gtable_0.3.1     zip_2.2.2        evaluate_0.20    knitr_1.42      
    [21] tzdb_0.3.0       fastmap_1.1.1    fansi_1.0.4      Rcpp_1.0.10     
    [25] scales_1.2.1     cachem_1.0.7     jsonlite_1.8.4   hms_1.1.2       
    [29] digest_0.6.31    stringi_1.7.12   grid_4.2.2       rprojroot_2.0.3 
    [33] cli_3.6.0        tools_4.2.2      magrittr_2.0.3   sass_0.4.5      
    [37] crayon_1.5.2     pkgconfig_2.0.3  ellipsis_0.3.2   timechange_0.2.0
    [41] rmarkdown_2.20   rstudioapi_0.14  R6_2.5.1         compiler_4.2.2  

RStudio version 2023.3.0.386.

------------------------------------------------------------------------

# Cite R packages used

    openxlsx 
     
     
    R.utils 
     
     
    tidyverse 
     
     

------------------------------------------------------------------------

END OF SCRIPT
