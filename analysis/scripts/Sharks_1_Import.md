Import dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-09-06 08:51:56 CEST

- [Goal of the script](#goal-of-the-script)
- [Load packages](#load-packages)
- [Get names and path all files](#get-names-and-path-all-files)
- [Read and format data](#read-and-format-data)
  - [Read in CSV files](#read-in-csv-files)
  - [Select relevant columns and
    rows](#select-relevant-columns-and-rows)
  - [Identify results using frame
    numbers](#identify-results-using-frame-numbers)
  - [Add headers](#add-headers)
  - [Extract units](#extract-units)
  - [Split column ‘Name’](#split-column-name)
  - [Convert to numeric](#convert-to-numeric)
  - [Add column for NMP categories](#add-column-for-nmp-categories)
  - [Read in CSV files of measurement
    positions](#read-in-csv-files-of-measurement-positions)
  - [Merge measurement positions with
    dataset](#merge-measurement-positions-with-dataset)
  - [Re-order columns and add units as
    comment](#re-order-columns-and-add-units-as-comment)
  - [Check the result](#check-the-result)
- [Save data](#save-data)
  - [Create file names](#create-file-names)
  - [Write to ODS and Rbin](#write-to-ods-and-rbin)
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
3.  Write ODS file and save R objects ready for further analysis in R

``` r
dir_in  <- "analysis/raw_data"
dir_out <- "analysis/derived_data"
```

Raw data must be located in “./analysis/raw_data”.  
Formatted data will be saved in “./analysis/derived_data”.

The knit directory for this script is the project directory.

------------------------------------------------------------------------

# Load packages

``` r
pack_to_load <- sort(c("R.utils", "readODS", "tidyverse", "rmarkdown", "knitr", "grateful"))
sapply(pack_to_load, library, character.only = TRUE, logical.return = TRUE) 
```

     grateful     knitr   R.utils   readODS rmarkdown tidyverse 
         TRUE      TRUE      TRUE      TRUE      TRUE      TRUE 

------------------------------------------------------------------------

# Get names and path all files

``` r
info_in <- list.files(dir_in, pattern = "\\.csv$", full.names = TRUE)
info_in
```

    [1] "analysis/raw_data/DMTA-Ctenacanths_100x.csv"          
    [2] "analysis/raw_data/DMTA-Ctenacanths_100x_positions.csv"
    [3] "analysis/raw_data/DMTA-Ctenacanths_20x.csv"           
    [4] "analysis/raw_data/DMTA-Ctenacanths_20x_positions.csv" 

------------------------------------------------------------------------

# Read and format data

## Read in CSV files

``` r
# Loop through list of CSV files and read in
sharks <- info_in %>% 
  
           # Subset relevant CSV files
           .[grepl("x.csv", .)] %>% 
  
           # Read in all relevant CSV files
           lapply(function(x) read.csv(x, header = FALSE, na.strings = "*****", 
                                       fileEncoding = 'WINDOWS-1252')) %>%
  
           # rbind together
           do.call(rbind, .)
```

## Select relevant columns and rows

``` r
sharks_keep_col  <- c(4, 26:55, 57:58, 61:64)                 # Define columns to keep
sharks_keep_rows <- which(sharks[[1]] != "#")                 # Define rows to keep
sharks_keep      <- sharks[sharks_keep_rows, sharks_keep_col] # Subset rows and columns
```

## Identify results using frame numbers

``` r
frames <- as.numeric(unlist(sharks[1, sharks_keep_col]))
ID <- which(frames %in% c(2, 11))
ISO <- which(frames == 15)
furrow <- which(frames == 16)
diriso <- which(frames %in% 17:18)
SSFA <- which(frames %in% 19:20)
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
                         gsub("\\.$", "", x = .)
  
#
colnames(sharks_keep)[ISO] <- strsplit(names(sharks_keep)[ISO], ".", fixed = TRUE) %>% 
                              sapply(`[[`, 1)
#
colnames(sharks_keep)[SSFA] <- gsub("^([A-Za-z0-9]+\\.)+", "", colnames(sharks_keep)[SSFA])

# Edit headers for name of surfaces and non-measured point ratios
colnames(sharks_keep)[ID] <- c("Name", "NMP")
```

## Extract units

``` r
# Filter out rows which contains units
n_units <- filter(sharks, V4 == "<no unit>") %>% 
          
           # Keep only unique/distinct rows of units
           distinct() %>% 
  
           # Number of unique/distinct rows of units
           nrow()

if (n_units != 1) {
  stop("The different datasets have different units")
} else {
  # Extract unit line from 3rd row for considered columns
  sharks_units <- unlist(sharks[3, sharks_keep_col[-1]])

  # Get names associated to the units
  names(sharks_units) <- colnames(sharks_keep)[-1]

  # Combine into a data.frame for export
  units_table <- data.frame(variable = names(sharks_units), units = sharks_units)
}
```

## Split column ‘Name’

``` r
sharks_keep[c("Specimen", "Tooth", "Location", "Objective", "Measurement")] <- str_split_fixed(
                                                                               sharks_keep$Name, "_", n = 5)
```

## Convert to numeric

``` r
# Replace "-nan(ind)" with NA in column HAsfc81
sharks_keep$HAsfc81 <- na_if(sharks_keep$HAsfc81, "-nan(ind)")

# Convert all parameter variables to numeric
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

The number of height maps for each objective in each NMP category is:

``` r
table(sharks_keep[c("NMP_cat", "Objective")])
```

            Objective
    NMP_cat  100x 20x
      <10%     47  38
      10-20%   28  31
      ≥20%      5  11

## Read in CSV files of measurement positions

``` r
meas_pos <- info_in %>% 
            .[grepl("positions", .)] %>% 
            lapply(function(x) read.csv2(x, fileEncoding = 'WINDOWS-1252')) %>%
            do.call(rbind, .)
str(meas_pos)
```

    'data.frame':   160 obs. of  2 variables:
     $ Name    : chr  "CC_A_loc1_100x_meas1" "CC_A_loc1_100x_meas2" "CC_A_loc1_100x_meas3" "CC_A_loc2_100x_meas1" ...
     $ Position: chr  "top" "top" "top" "bottom" ...

``` r
head(meas_pos)
```

                      Name Position
    1 CC_A_loc1_100x_meas1      top
    2 CC_A_loc1_100x_meas2      top
    3 CC_A_loc1_100x_meas3      top
    4 CC_A_loc2_100x_meas1   bottom
    5 CC_A_loc2_100x_meas2   bottom
    6 CC_A_loc2_100x_meas3   bottom

## Merge measurement positions with dataset

``` r
sharks_keep_pos <- merge(sharks_keep, meas_pos, by = "Name", all.x = TRUE)
```

## Re-order columns and add units as comment

``` r
sharks_final <- select(sharks_keep_pos, Specimen:Measurement, Position, NMP, NMP_cat, Sq:HAsfc81)
comment(sharks_final) <- sharks_units
```

Type `comment(sharks_final)` to check the units of the parameters.

## Check the result

``` r
str(sharks_final)
```

    'data.frame':   160 obs. of  43 variables:
     $ Specimen                : chr  "CC" "CC" "CC" "CC" ...
     $ Tooth                   : chr  "A" "A" "A" "A" ...
     $ Location                : chr  "loc1" "loc1" "loc1" "loc1" ...
     $ Objective               : chr  "100x" "100x" "100x" "20x" ...
     $ Measurement             : chr  "meas1" "meas2" "meas3" "meas1" ...
     $ Position                : chr  "top" "top" "top" "top" ...
     $ NMP                     : num  3.03 3.05 3.34 12.54 11.63 ...
     $ NMP_cat                 : Ord.factor w/ 3 levels "<10%"<"10-20%"<..: 1 1 1 2 2 2 1 1 1 3 ...
     $ Sq                      : num  1.22 1.18 1.16 7.28 7.29 ...
     $ Ssk                     : num  -0.332 -0.345 -0.355 0.83 0.814 ...
     $ Sku                     : num  2.53 2.45 2.42 3.15 3.14 ...
     $ Sp                      : num  2.74 2.73 2.69 22.04 22.01 ...
     $ Sv                      : num  3.42 3.25 3.17 17.88 19.03 ...
     $ Sz                      : num  6.16 5.98 5.86 39.92 41.04 ...
     $ Sa                      : num  0.995 0.969 0.956 5.8 5.803 ...
     $ Smr                     : num  5.865 4.991 4.781 0.189 0.183 ...
     $ Smc                     : num  1.5 1.47 1.43 11.42 11.45 ...
     $ Sxp                     : num  2.62 2.5 2.48 8.72 8.84 ...
     $ Sal                     : num  20.7 20.4 20.3 91.8 91.5 ...
     $ Str                     : num  0.557 0.53 0.537 NA NA ...
     $ Std                     : num  58.5 58.5 58.5 58.5 58.7 ...
     $ Ssw                     : num  0.658 0.658 0.658 3.295 3.295 ...
     $ Sdq                     : num  0.179 0.176 0.176 0.252 0.257 ...
     $ Sdr                     : num  1.51 1.47 1.46 2.97 3.08 ...
     $ Vm                      : num  0.0382 0.033 0.032 0.4189 0.414 ...
     $ Vv                      : num  1.54 1.5 1.47 11.84 11.86 ...
     $ Vmp                     : num  0.0382 0.033 0.032 0.4189 0.414 ...
     $ Vmc                     : num  1.21 1.18 1.15 5.85 5.88 ...
     $ Vvc                     : num  1.39 1.35 1.32 11.35 11.37 ...
     $ Vvv                     : num  0.148 0.148 0.147 0.487 0.496 ...
     $ Maximum.depth.of.furrows: num  2.33 2.29 2.29 41.48 39.05 ...
     $ Mean.depth.of.furrows   : num  0.834 0.808 0.792 18.822 18.342 ...
     $ Mean.density.of.furrows : num  2027 2022 2034 1354 1319 ...
     $ First.direction         : num  37 37 37 90 90 ...
     $ Second.direction        : num  56.5 90 90 37 37 ...
     $ Third.direction         : num  90 56.6 56.6 56.5 56.5 ...
     $ Texture.isotropy        : num  47.3 51.9 58.7 21 21 ...
     $ epLsar                  : num  0.00119 0.00113 0.00124 0.00347 0.00337 ...
     $ NewEplsar               : num  0.0172 0.0172 0.0173 0.0163 0.0164 ...
     $ Asfc                    : num  1.85 1.79 1.82 6.64 6.88 ...
     $ Smfc                    : num  86.2 48.8 52 12.9 12.9 ...
     $ HAsfc9                  : num  0.249 0.233 0.172 0.364 0.363 ...
     $ HAsfc81                 : num  0.591 0.582 0.516 0.486 0.459 ...
     - attr(*, "comment")= Named chr [1:36] "%" "µm" "<no unit>" "<no unit>" ...
      ..- attr(*, "names")= chr [1:36] "NMP" "Sq" "Ssk" "Sku" ...

``` r
head(sharks_final)
```

      Specimen Tooth Location Objective Measurement Position       NMP NMP_cat
    1       CC     A     loc1      100x       meas1      top  3.029439    <10%
    2       CC     A     loc1      100x       meas2      top  3.049307    <10%
    3       CC     A     loc1      100x       meas3      top  3.344563    <10%
    4       CC     A     loc1       20x       meas1      top 12.535975  10-20%
    5       CC     A     loc1       20x       meas2      top 11.627484  10-20%
    6       CC     A     loc1       20x       meas3      top 11.532629  10-20%
            Sq        Ssk      Sku        Sp        Sv        Sz        Sa
    1 1.216901 -0.3324891 2.531089  2.739170  3.419274  6.158444 0.9953219
    2 1.179617 -0.3453720 2.445014  2.728211  3.249398  5.977609 0.9692665
    3 1.159639 -0.3552218 2.419064  2.691938  3.171959  5.863897 0.9563751
    4 7.283899  0.8300851 3.150191 22.041760 17.879370 39.921130 5.8003993
    5 7.291346  0.8135181 3.143032 22.005620 19.034020 41.039640 5.8025693
    6 7.299769  0.7937514 3.133681 21.947290 19.597010 41.544300 5.8089293
            Smr       Smc      Sxp      Sal       Str      Std       Ssw       Sdq
    1 5.8654996  1.501282 2.616679 20.72644 0.5567234 58.51426 0.6583791 0.1788874
    2 4.9913841  1.466514 2.496966 20.41661 0.5302128 58.51580 0.6583791 0.1762588
    3 4.7814041  1.433144 2.478542 20.34239 0.5374210 58.51426 0.6583791 0.1757932
    4 0.1894798 11.422816 8.719022 91.81795        NA 58.51104 3.2947348 0.2516132
    5 0.1831192 11.447557 8.835691 91.52523        NA 58.74993 3.2947348 0.2565464
    6 0.1789167 11.420322 8.937201 91.26699        NA 58.50948 3.2947348 0.2573718
           Sdr         Vm        Vv        Vmp      Vmc       Vvc       Vvv
    1 1.506669 0.03822744  1.539509 0.03822744 1.208085  1.391427 0.1480817
    2 1.467242 0.03300682  1.499521 0.03300682 1.177222  1.351987 0.1475341
    3 1.461778 0.03196542  1.465109 0.03196542 1.152959  1.318489 0.1466205
    4 2.969515 0.41885768 11.841674 0.41885768 5.853784 11.354906 0.4867681
    5 3.077962 0.41399141 11.861548 0.41399141 5.876793 11.365137 0.4964114
    6 3.094444 0.41329807 11.833616 0.41329807 5.893694 11.326966 0.5066504
      Maximum.depth.of.furrows Mean.depth.of.furrows Mean.density.of.furrows
    1                 2.330753             0.8337031                2026.884
    2                 2.286745             0.8079501                2022.394
    3                 2.291874             0.7918662                2033.563
    4                41.483780            18.8223490                1353.924
    5                39.054195            18.3416154                1318.768
    6                36.911570            18.3032455                1322.121
      First.direction Second.direction Third.direction Texture.isotropy      epLsar
    1        37.00334         56.54720        89.98706         47.34345 0.001190735
    2        37.00374         90.00751        56.55262         51.88475 0.001128928
    3        37.00464         89.99660        56.55126         58.70932 0.001244379
    4        89.99845         37.00583        56.52640         20.95764 0.003465575
    5        90.00132         37.00101        56.51804         20.96000 0.003372058
    6        90.00973         37.00585        56.52725         20.91598 0.003303745
       NewEplsar     Asfc     Smfc    HAsfc9   HAsfc81
    1 0.01718885 1.851713 86.15295 0.2487842 0.5906368
    2 0.01723834 1.787470 48.78199 0.2329559 0.5822596
    3 0.01734807 1.822078 51.96430 0.1722548 0.5164332
    4 0.01632353 6.642577 12.86064 0.3637900 0.4857648
    5 0.01638856 6.882199 12.86064 0.3629004 0.4593461
    6 0.01641245 7.008048 12.86064 0.3699310 0.4620558

------------------------------------------------------------------------

# Save data

## Create file names

``` r
sharks_ods <- paste0(dir_out, "/DMTA-Ctenacanths.ods")
sharks_rbin <- paste0(dir_out, "/DMTA-Ctenacanths.Rbin")
```

## Write to ODS and Rbin

``` r
write_ods(list("data" = sharks_final, "units" = units_table), path = sharks_ods) 
saveObject(sharks_final, file = sharks_rbin) 
```

Rbin files (e.g. `DMTA-Ctenacanths.Rbin`) can be easily read into an R
object (e.g. `rbin_data`) using the following code:

``` r
library(R.utils)
rbin_data <- loadObject("DMTA-Ctenacanths.Rbin")
```

------------------------------------------------------------------------

# sessionInfo()

``` r
sessionInfo()
```

    R version 4.3.1 (2023-06-16 ucrt)
    Platform: x86_64-w64-mingw32/x64 (64-bit)
    Running under: Windows 10 x64 (build 19045)

    Matrix products: default


    locale:
    [1] LC_COLLATE=French_France.utf8  LC_CTYPE=French_France.utf8   
    [3] LC_MONETARY=French_France.utf8 LC_NUMERIC=C                  
    [5] LC_TIME=French_France.utf8    

    time zone: Europe/Berlin
    tzcode source: internal

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] lubridate_1.9.2   forcats_1.0.0     stringr_1.5.0     dplyr_1.1.2      
     [5] purrr_1.0.2       readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
     [9] ggplot2_3.4.3     tidyverse_2.0.0   rmarkdown_2.24    readODS_2.0.7    
    [13] R.utils_2.12.2    R.oo_1.25.0       R.methodsS3_1.8.2 knitr_1.43       
    [17] grateful_0.2.0   

    loaded via a namespace (and not attached):
     [1] sass_0.4.7        utf8_1.2.3        generics_0.1.3    stringi_1.7.12   
     [5] hms_1.1.3         digest_0.6.33     magrittr_2.0.3    evaluate_0.21    
     [9] grid_4.3.1        timechange_0.2.0  fastmap_1.1.1     rprojroot_2.0.3  
    [13] jsonlite_1.8.7    zip_2.3.0         fansi_1.0.4       scales_1.2.1     
    [17] jquerylib_0.1.4   cli_3.6.1         rlang_1.1.1       crayon_1.5.2     
    [21] munsell_0.5.0     withr_2.5.0       cachem_1.0.8      yaml_2.3.7       
    [25] tools_4.3.1       tzdb_0.4.0        colorspace_2.1-0  vctrs_0.6.3      
    [29] R6_2.5.1          lifecycle_1.0.3   pkgconfig_2.0.3   pillar_1.9.0     
    [33] bslib_0.5.1       gtable_0.3.4      glue_1.6.2        xfun_0.40        
    [37] tidyselect_1.2.0  rstudioapi_0.15.0 htmltools_0.5.6   compiler_4.3.1   

------------------------------------------------------------------------

# Cite R packages used

| Package   | Version | Citation                                                                                      |
|:----------|:--------|:----------------------------------------------------------------------------------------------|
| base      | 4.3.1   | R Core Team (2023)                                                                            |
| grateful  | 0.2.0   | Francisco Rodríguez-Sánchez, Connor P. Jackson, and Shaurita D. Hutchins (2023)               |
| knitr     | 1.43    | Xie (2014); Xie (2015); Xie (2023)                                                            |
| R.utils   | 2.12.2  | Bengtsson (2022)                                                                              |
| readODS   | 2.0.7   | Schutten et al. (2023)                                                                        |
| rmarkdown | 2.24    | Xie, Allaire, and Grolemund (2018); Xie, Dervieux, and Riederer (2020); Allaire et al. (2023) |
| tidyverse | 2.0.0   | Wickham et al. (2019)                                                                         |

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

<div id="ref-base" class="csl-entry">

R Core Team. 2023. *R: A Language and Environment for Statistical
Computing*. Vienna, Austria: R Foundation for Statistical Computing.
<https://www.R-project.org/>.

</div>

<div id="ref-readODS" class="csl-entry">

Schutten, Gerrit-Jan, Chung-hong Chan, Peter Brohan, Detlef Steuer, and
Thomas J. Leeper. 2023. *<span class="nocase">readODS</span>: Read and
Write ODS Files*. <https://github.com/ropensci/readODS>.

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
