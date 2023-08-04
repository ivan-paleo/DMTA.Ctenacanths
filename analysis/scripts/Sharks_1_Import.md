Import dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-08-04 11:22:56 CEST

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
dir_in  <- "analysis/raw_data"
dir_out <- "analysis/derived_data"
```

Raw data must be located in “./analysis/raw_data”.  
Formatted data will be saved in “./analysis/derived_data”.

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

    [1] "analysis/raw_data/DMTA-Ctenacanths_100x.csv"
    [2] "analysis/raw_data/DMTA-Ctenacanths_20x.csv" 

------------------------------------------------------------------------

# Read and format data

## Read in CSV files

``` r
# Loop through list of CSV files and read in
sharks <- lapply(info_in, function(x) read.csv(x, header = FALSE, na.strings = "*****", 
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
colnames(sharks_keep)[ID] <- c("Surface.Name", "NMP")
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
                                                                               sharks_keep$Surface.Name, "_", n = 5)
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

## Re-order columns and add units as comment

``` r
sharks_final <- select(sharks_keep, Specimen:Measurement, NMP, NMP_cat, Sq:HAsfc81)
comment(sharks_final) <- sharks_units
```

Type `comment(sharks_final)` to check the units of the parameters.

## Check the result

``` r
str(sharks_final)
```

    'data.frame':   160 obs. of  42 variables:
     $ Specimen                : chr  "CC" "CC" "CC" "CC" ...
     $ Tooth                   : chr  "A" "A" "A" "A" ...
     $ Location                : chr  "loc1" "loc1" "loc1" "loc2" ...
     $ Objective               : chr  "100x" "100x" "100x" "100x" ...
     $ Measurement             : chr  "meas1" "meas2" "meas3" "meas1" ...
     $ NMP                     : num  3.03 3.05 3.34 9.84 9.78 ...
     $ NMP_cat                 : Ord.factor w/ 3 levels "<10%"<"10-20%"<..: 1 1 1 1 1 1 2 2 2 1 ...
     $ Sq                      : num  1.22 1.18 1.16 1.66 1.66 ...
     $ Ssk                     : num  -0.332 -0.345 -0.355 1.53 1.454 ...
     $ Sku                     : num  2.53 2.45 2.42 8.22 7.72 ...
     $ Sp                      : num  2.74 2.73 2.69 8.77 8.39 ...
     $ Sv                      : num  3.42 3.25 3.17 3.39 3.45 ...
     $ Sz                      : num  6.16 5.98 5.86 12.16 11.84 ...
     $ Sa                      : num  0.995 0.969 0.956 1.14 1.154 ...
     $ Smr                     : num  5.865 4.991 4.781 0.361 0.405 ...
     $ Smc                     : num  1.5 1.47 1.43 1.3 1.32 ...
     $ Sxp                     : num  2.62 2.5 2.48 2.77 2.76 ...
     $ Sal                     : num  20.7 20.4 20.3 15.3 15.2 ...
     $ Str                     : num  0.557 0.53 0.537 0.408 0.396 ...
     $ Std                     : num  58.5 58.5 58.5 84.5 84.5 ...
     $ Ssw                     : num  0.658 0.658 0.658 0.658 0.658 ...
     $ Sdq                     : num  0.179 0.176 0.176 0.409 0.395 ...
     $ Sdr                     : num  1.51 1.47 1.46 4.86 4.71 ...
     $ Vm                      : num  0.0382 0.033 0.032 0.2068 0.2047 ...
     $ Vv                      : num  1.54 1.5 1.47 1.51 1.53 ...
     $ Vmp                     : num  0.0382 0.033 0.032 0.2068 0.2047 ...
     $ Vmc                     : num  1.21 1.18 1.15 1.16 1.18 ...
     $ Vvc                     : num  1.39 1.35 1.32 1.35 1.37 ...
     $ Vvv                     : num  0.148 0.148 0.147 0.154 0.155 ...
     $ Maximum.depth.of.furrows: num  2.33 2.29 2.29 4.51 4.52 ...
     $ Mean.depth.of.furrows   : num  0.834 0.808 0.792 1.292 1.286 ...
     $ Mean.density.of.furrows : num  2027 2022 2034 2211 2229 ...
     $ First.direction         : num  37 37 37 90 90 ...
     $ Second.direction        : num  56.5 90 90 84.3 84.3 ...
     $ Third.direction         : num  90 56.6 56.6 78.7 78.7 ...
     $ Texture.isotropy        : num  47.3 51.9 58.7 72.8 68 ...
     $ epLsar                  : num  0.00119 0.00113 0.00124 0.00152 0.0018 ...
     $ NewEplsar               : num  0.0172 0.0172 0.0173 0.0176 0.0177 ...
     $ Asfc                    : num  1.85 1.79 1.82 9.4 7.54 ...
     $ Smfc                    : num  86.2 48.8 52 37.9 62.8 ...
     $ HAsfc9                  : num  0.249 0.233 0.172 3.11 1.59 ...
     $ HAsfc81                 : num  0.591 0.582 0.516 4.706 5.056 ...
     - attr(*, "comment")= Named chr [1:36] "%" "µm" "<no unit>" "<no unit>" ...
      ..- attr(*, "names")= chr [1:36] "NMP" "Sq" "Ssk" "Sku" ...

``` r
head(sharks_final)
```

      Specimen Tooth Location Objective Measurement      NMP NMP_cat       Sq
    4       CC     A     loc1      100x       meas1 3.029439    <10% 1.216901
    5       CC     A     loc1      100x       meas2 3.049307    <10% 1.179617
    6       CC     A     loc1      100x       meas3 3.344563    <10% 1.159639
    7       CC     A     loc2      100x       meas1 9.838464    <10% 1.656338
    8       CC     A     loc2      100x       meas2 9.778688    <10% 1.660077
    9       CC     A     loc2      100x       meas3 9.676411    <10% 1.672438
             Ssk      Sku       Sp       Sv        Sz        Sa       Smr      Smc
    4 -0.3324891 2.531089 2.739170 3.419274  6.158444 0.9953219 5.8654996 1.501282
    5 -0.3453720 2.445014 2.728211 3.249398  5.977609 0.9692665 4.9913841 1.466514
    6 -0.3552218 2.419064 2.691938 3.171959  5.863897 0.9563751 4.7814041 1.433144
    7  1.5304097 8.222025 8.770563 3.392293 12.162856 1.1397393 0.3605701 1.299871
    8  1.4536571 7.720735 8.385795 3.451509 11.837304 1.1538744 0.4047778 1.323791
    9  1.3428177 7.123336 8.221306 3.535302 11.756608 1.1745203 0.3790766 1.340443
           Sxp      Sal       Str      Std       Ssw       Sdq      Sdr         Vm
    4 2.616679 20.72644 0.5567234 58.51426 0.6583791 0.1788874 1.506669 0.03822744
    5 2.496966 20.41661 0.5302128 58.51580 0.6583791 0.1762588 1.467242 0.03300682
    6 2.478542 20.34239 0.5374210 58.51426 0.6583791 0.1757932 1.461778 0.03196542
    7 2.773392 15.28407 0.4082060 84.49350 0.6583791 0.4089966 4.864301 0.20681889
    8 2.764030 15.15797 0.3964592 84.49088 0.6583791 0.3952110 4.711679 0.20466698
    9 2.785413 15.04554 0.3796597 84.49234 0.6583791 0.4100509 4.876693 0.20529636
            Vv        Vmp      Vmc      Vvc       Vvv Maximum.depth.of.furrows
    4 1.539509 0.03822744 1.208085 1.391427 0.1480817                 2.330753
    5 1.499521 0.03300682 1.177222 1.351987 0.1475341                 2.286745
    6 1.465109 0.03196542 1.152959 1.318489 0.1466205                 2.291874
    7 1.506690 0.20681889 1.155887 1.352251 0.1544399                 4.505557
    8 1.528458 0.20466698 1.179001 1.373821 0.1546366                 4.519094
    9 1.545739 0.20529636 1.218516 1.389702 0.1560377                 4.589052
      Mean.depth.of.furrows Mean.density.of.furrows First.direction
    4             0.8337031                2026.884        37.00334
    5             0.8079501                2022.394        37.00374
    6             0.7918662                2033.563        37.00464
    7             1.2923442                2210.950        90.00308
    8             1.2861711                2228.890        89.99409
    9             1.3129296                2198.418        90.00073
      Second.direction Third.direction Texture.isotropy      epLsar  NewEplsar
    4         56.54720        89.98706         47.34345 0.001190735 0.01718885
    5         90.00751        56.55262         51.88475 0.001128928 0.01723834
    6         89.99660        56.55126         58.70932 0.001244379 0.01734807
    7         84.27736        78.66287         72.77926 0.001522344 0.01759510
    8         84.26899        78.65584         68.00086 0.001796346 0.01773082
    9         84.26877       142.98863         65.80603 0.001234300 0.01778692
          Asfc     Smfc    HAsfc9   HAsfc81
    4 1.851713 86.15295 0.2487842 0.5906368
    5 1.787470 48.78199 0.2329559 0.5822596
    6 1.822078 51.96430 0.1722548 0.5164332
    7 9.401217 37.88585 3.1102284 4.7057083
    8 7.539994 62.81191 1.5898377 5.0555013
    9 7.913469 51.96430 1.2035583 3.9106375

------------------------------------------------------------------------

# Save data

## Create file names

``` r
sharks_xlsx <- paste0(dir_out, "/DMTA-Ctenacanths.xlsx")
sharks_rbin <- paste0(dir_out, "/DMTA-Ctenacanths.Rbin")
```

## Write to XLSX and Rbin

``` r
write.xlsx(list(data = sharks_final, units = units_table), file = sharks_xlsx) 
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
     [5] purrr_1.0.1       readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
     [9] ggplot2_3.4.2     tidyverse_2.0.0   rmarkdown_2.23    R.utils_2.12.2   
    [13] R.oo_1.25.0       R.methodsS3_1.8.2 openxlsx_4.2.5.2  knitr_1.43       
    [17] grateful_0.2.0   

    loaded via a namespace (and not attached):
     [1] sass_0.4.7        utf8_1.2.3        generics_0.1.3    stringi_1.7.12   
     [5] hms_1.1.3         digest_0.6.33     magrittr_2.0.3    timechange_0.2.0 
     [9] evaluate_0.21     grid_4.3.1        fastmap_1.1.1     rprojroot_2.0.3  
    [13] jsonlite_1.8.7    zip_2.3.0         fansi_1.0.4       scales_1.2.1     
    [17] jquerylib_0.1.4   cli_3.6.1         rlang_1.1.1       crayon_1.5.2     
    [21] munsell_0.5.0     withr_2.5.0       cachem_1.0.8      yaml_2.3.7       
    [25] tools_4.3.1       tzdb_0.4.0        colorspace_2.1-0  vctrs_0.6.3      
    [29] R6_2.5.1          lifecycle_1.0.3   pkgconfig_2.0.3   pillar_1.9.0     
    [33] bslib_0.5.0       gtable_0.3.3      glue_1.6.2        Rcpp_1.0.11      
    [37] xfun_0.39         tidyselect_1.2.0  rstudioapi_0.15.0 htmltools_0.5.5  
    [41] compiler_4.3.1   

------------------------------------------------------------------------

# Cite R packages used

We used R version 4.3.1 (R Core Team 2023) and the following R packages:
grateful v. 0.2.0 (Francisco Rodríguez-Sánchez, Connor P. Jackson, and
Shaurita D. Hutchins 2023), knitr v. 1.43 (Xie 2014, 2015, 2023),
openxlsx v. 4.2.5.2 (Schauberger and Walker 2023), R.utils v. 2.12.2
(Bengtsson 2022), rmarkdown v. 2.23 (Xie, Allaire, and Grolemund 2018;
Xie, Dervieux, and Riederer 2020; Allaire et al. 2023), tidyverse v.
2.0.0 (Wickham et al. 2019), running in RStudio v. 2023.6.1.524 (Posit
team 2023).

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

<div id="ref-base" class="csl-entry">

R Core Team. 2023. *R: A Language and Environment for Statistical
Computing*. Vienna, Austria: R Foundation for Statistical Computing.
<https://www.R-project.org/>.

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
