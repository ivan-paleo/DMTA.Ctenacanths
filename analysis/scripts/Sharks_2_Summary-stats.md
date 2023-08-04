Summary statistics on dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-08-04 11:23:49 CEST

- [Goal of the script](#goal-of-the-script)
- [Load packages](#load-packages)
- [Read in data](#read-in-data)
  - [Get name and path of input file](#get-name-and-path-of-input-file)
  - [Read in Rbin file](#read-in-rbin-file)
- [Summary statistics](#summary-statistics)
  - [Create function to compute the statistics at
    once](#create-function-to-compute-the-statistics-at-once)
  - [Define grouping and numerical variables to
    use](#define-grouping-and-numerical-variables-to-use)
  - [Compute summary statistics](#compute-summary-statistics)
  - [Add units](#add-units)
- [Write results to XLSX](#write-results-to-xlsx)
- [sessionInfo()](#sessioninfo)
- [Cite R packages used](#cite-r-packages-used)
  - [References](#references)

------------------------------------------------------------------------

# Goal of the script

This script computes standard descriptive statistics for each group.  
The groups are based on:

- Specimen  
- Tooth position  
- NMP_cat

It computes the following statistics:

- sample size (n = `length`)  
- smallest value (`min`)  
- largest value (`max`)
- mean  
- median  
- standard deviation (`sd`)

``` r
dir_in  <- "analysis/derived_data"
dir_out <- "analysis/stats"
```

Input Rbin data file must be located in “./analysis/derived_data”.  
Summary statistics table will be saved in “./analysis/stats”.

The knit directory for this script is the project directory.

------------------------------------------------------------------------

# Load packages

``` r
pack_to_load <- c("doBy", "grateful", "knitr", "openxlsx", "R.utils", "rmarkdown", "tidyverse")
sapply(pack_to_load, library, character.only = TRUE, logical.return = TRUE) 
```

         doBy  grateful     knitr  openxlsx   R.utils rmarkdown tidyverse 
         TRUE      TRUE      TRUE      TRUE      TRUE      TRUE      TRUE 

------------------------------------------------------------------------

# Read in data

## Get name and path of input file

``` r
info_in <- list.files(dir_in, pattern = "\\.Rbin$", full.names = TRUE)
info_in
```

    [1] "analysis/derived_data/DMTA-Ctenacanths.Rbin"

## Read in Rbin file

``` r
sharks <- loadObject(info_in)
str(sharks)
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

------------------------------------------------------------------------

# Summary statistics

## Create function to compute the statistics at once

``` r
nminmaxmeanmedsd <- function(x){
    y <- x[!is.na(x)]     # Exclude NAs
    n_test <- length(y)   # Sample size (n)
    min_test <- min(y)    # Minimum
    max_test <- max(y)    # Maximum
    mean_test <- mean(y)  # Mean
    med_test <- median(y) # Median
    sd_test <- sd(y)      # Standard deviation
    out <- c(n_test, min_test, max_test, mean_test, med_test, sd_test) # Concatenate
    names(out) <- c("n", "min", "max", "mean", "median", "sd")         # Name values
    return(out)                                                        # Object to return
}
```

## Define grouping and numerical variables to use

``` r
# Define grouping variables: Specimen + NMP_cat
grp1 <- c("Specimen", "NMP_cat")

# Define grouping variables: Specimen + Tooth
grp2 <- c("Specimen", "Tooth")

# Define grouping variables: Specimen + Tooth + NMP_cat
grp3 <- c("Specimen", "Tooth", "NMP_cat")
```

The following grouping variables will be used:

- First set `grp1`

<!-- -->

    Specimen
    NMP_cat

- Second set `grp2`

<!-- -->

    Specimen
    Tooth

- Third set `grp3`

<!-- -->

    Specimen
    Tooth
    NMP_cat

All numerical variables except `NMP` will be used:

    Sq
    Ssk
    Sku
    Sp
    Sv
    Sz
    Sa
    Smr
    Smc
    Sxp
    Sal
    Str
    Std
    Ssw
    Sdq
    Sdr
    Vm
    Vv
    Vmp
    Vmc
    Vvc
    Vvv
    Maximum.depth.of.furrows
    Mean.depth.of.furrows
    Mean.density.of.furrows
    First.direction
    Second.direction
    Third.direction
    Texture.isotropy
    epLsar
    NewEplsar
    Asfc
    Smfc
    HAsfc9
    HAsfc81

## Compute summary statistics

``` r
# grp1
# Create formula based on grouping variables in grp1
stats_grp1 <- as.formula(paste(".~", paste(grp1, collapse = "+"))) %>% 
  
              # calculate group-wise stats
              summaryBy(data = sharks, FUN = nminmaxmeanmedsd)
```

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

``` r
# Same with grp2
stats_grp2 <- as.formula(paste(".~", paste(grp2, collapse = "+"))) %>% 
              summaryBy(data = sharks, FUN = nminmaxmeanmedsd)

# Same with grp3
stats_grp3 <- as.formula(paste(".~", paste(grp3, collapse = "+"))) %>% 
              summaryBy(data = sharks, FUN = nminmaxmeanmedsd)
```

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in min(y): no non-missing arguments to max; returning -Inf

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

## Add units

``` r
# Extract units from comment(sharks) and exclude first row (NMP)
units_stats <- data.frame(variable = names(comment(sharks)), units = comment(sharks))[-1,]
```

------------------------------------------------------------------------

# Write results to XLSX

``` r
write.xlsx(list(Specimen_NMP = stats_grp1, Specimen_Tooth = stats_grp2, Specimen_Tooth_NMP = stats_grp3, 
                units = units_stats), file = paste0(dir_out, "/DMTA-Ctenacanths_summary-stats.xlsx"))
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
    [17] grateful_0.2.0    doBy_4.6.17      

    loaded via a namespace (and not attached):
     [1] sass_0.4.7            utf8_1.2.3            generics_0.1.3       
     [4] stringi_1.7.12        lattice_0.21-8        hms_1.1.3            
     [7] digest_0.6.33         magrittr_2.0.3        timechange_0.2.0     
    [10] evaluate_0.21         grid_4.3.1            fastmap_1.1.1        
    [13] rprojroot_2.0.3       jsonlite_1.8.7        Matrix_1.5-4.1       
    [16] zip_2.3.0             backports_1.4.1       fansi_1.0.4          
    [19] scales_1.2.1          microbenchmark_1.4.10 jquerylib_0.1.4      
    [22] cli_3.6.1             rlang_1.1.1           crayon_1.5.2         
    [25] munsell_0.5.0         withr_2.5.0           cachem_1.0.8         
    [28] yaml_2.3.7            tools_4.3.1           tzdb_0.4.0           
    [31] colorspace_2.1-0      Deriv_4.1.3           broom_1.0.5          
    [34] vctrs_0.6.3           R6_2.5.1              lifecycle_1.0.3      
    [37] MASS_7.3-60           pkgconfig_2.0.3       pillar_1.9.0         
    [40] bslib_0.5.0           gtable_0.3.3          glue_1.6.2           
    [43] Rcpp_1.0.11           xfun_0.39             tidyselect_1.2.0     
    [46] rstudioapi_0.15.0     htmltools_0.5.5       compiler_4.3.1       

------------------------------------------------------------------------

# Cite R packages used

We used R version 4.3.1 (R Core Team 2023) and the following R packages:
doBy v. 4.6.17 (Højsgaard and Halekoh 2023), grateful v. 0.2.0
(Francisco Rodríguez-Sánchez, Connor P. Jackson, and Shaurita D.
Hutchins 2023), knitr v. 1.43 (Xie 2014, 2015, 2023), openxlsx v.
4.2.5.2 (Schauberger and Walker 2023), R.utils v. 2.12.2 (Bengtsson
2022), rmarkdown v. 2.23 (Xie, Allaire, and Grolemund 2018; Xie,
Dervieux, and Riederer 2020; Allaire et al. 2023), tidyverse v. 2.0.0
(Wickham et al. 2019), running in RStudio v. 2023.6.1.524 (Posit team
2023).

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

<div id="ref-doBy" class="csl-entry">

Højsgaard, Søren, and Ulrich Halekoh. 2023.
*<span class="nocase">doBy</span>: Groupwise Statistics, LSmeans, Linear
Estimates, Utilities*. <https://CRAN.R-project.org/package=doBy>.

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
