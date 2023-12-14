Summary statistics on dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-12-14 14:44:12 CET

- [Goal of the script](#goal-of-the-script)
- [Load packages](#load-packages)
- [Read in data](#read-in-data)
  - [Get name and path of input file](#get-name-and-path-of-input-file)
  - [Read in Rbin file](#read-in-rbin-file)
- [Summary statistics](#summary-statistics)
  - [Create function to compute the statistics at
    once](#create-function-to-compute-the-statistics-at-once)
  - [Define grouping and numeric variables to
    use](#define-grouping-and-numeric-variables-to-use)
  - [Compute summary statistics](#compute-summary-statistics)
  - [Add units](#add-units)
- [Write results to ODS](#write-results-to-ods)
- [sessionInfo()](#sessioninfo)
- [Cite R packages used](#cite-r-packages-used)
  - [References](#references)

------------------------------------------------------------------------

# Goal of the script

This script computes standard descriptive statistics for each group.  
The groups are based on:

- Objective  
- Specimen  
- Tooth  
- Position  
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
library(doBy)
library(grateful)
library(knitr)
library(R.utils)
library(readODS)
library(rmarkdown)
library(tidyverse)
```

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

## Define grouping and numeric variables to use

``` r
# Create list for grouping
sharks_grps <- vector(mode = "list", length = 5)
names(sharks_grps) <- c("Obj_Spec_NMP", "Obj_Spec_Tooth", "Obj_Spec_Pos", 
                        "Obj_Spec_Tooth_NMP", "Obj_Spec_Pos_NMP")

# Define grouping variables: Objective + Specimen + NMP_cat
sharks_grps[[1]] <- c("Objective", "Specimen", "NMP_cat")

# Define grouping variables: Objective + Specimen + Tooth
sharks_grps[[2]] <- c("Objective", "Specimen", "Tooth")

# Define grouping variables: Objective + Specimen + Position
sharks_grps[[3]] <- c("Objective", "Specimen", "Position")

# Define grouping variables: Objective + Specimen + Tooth + NMP_cat
sharks_grps[[4]] <- c("Objective", "Specimen", "Tooth", "NMP_cat")

# Define grouping variables: Objective + Specimen + Position + NMP_cat
sharks_grps[[5]] <- c("Objective", "Specimen", "Position", "NMP_cat")
```

The following grouping variables will be used:

    Set 1 : Obj_Spec_NMP 
    Objective Specimen NMP_cat 
     
    Set 2 : Obj_Spec_Tooth 
    Objective Specimen Tooth 
     
    Set 3 : Obj_Spec_Pos 
    Objective Specimen Position 
     
    Set 4 : Obj_Spec_Tooth_NMP 
    Objective Specimen Tooth NMP_cat 
     
    Set 5 : Obj_Spec_Pos_NMP 
    Objective Specimen Position NMP_cat 
     

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
# Create list for summary stats
stats_grps <- vector(mode = "list", length = 5)
names(stats_grps) <- names(sharks_grps)

# Calculate summary stats iteratively
for (i in seq_along(stats_grps)) {
  
  # Create formula based on grouping variables in grp1
  stats_grps[[i]] <- as.formula(paste(".~", paste(sharks_grps[[i]], collapse = "+"))) %>% 
  
                     # calculate group-wise stats
                     summaryBy(data = sharks, FUN = nminmaxmeanmedsd)
}
```

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

    Warning in min(y): no non-missing arguments to min; returning Inf

    Warning in max(y): no non-missing arguments to max; returning -Inf

## Add units

``` r
# Extract units from comment(sharks) and exclude first row (NMP)
units_stats <- data.frame(variable = names(comment(sharks)), units = comment(sharks))[-1,]
```

------------------------------------------------------------------------

# Write results to ODS

``` r
write_ods(stats_grps, path = paste0(dir_out, "/DMTA-Ctenacanths_summary-stats.ods"))
```

------------------------------------------------------------------------

# sessionInfo()

``` r
sessionInfo()
```

    R version 4.3.2 (2023-10-31 ucrt)
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
    [1] stats     graphics  grDevices datasets  utils     methods   base     

    other attached packages:
     [1] lubridate_1.9.3   forcats_1.0.0     stringr_1.5.1     dplyr_1.1.4      
     [5] purrr_1.0.2       readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
     [9] ggplot2_3.4.4     tidyverse_2.0.0   rmarkdown_2.25    readODS_2.1.0    
    [13] R.utils_2.12.3    R.oo_1.25.0       R.methodsS3_1.8.2 knitr_1.45       
    [17] grateful_0.2.4    doBy_4.6.20      

    loaded via a namespace (and not attached):
     [1] sass_0.4.8            utf8_1.2.4            generics_0.1.3       
     [4] renv_1.0.3            stringi_1.8.3         lattice_0.21-9       
     [7] hms_1.1.3             digest_0.6.33         magrittr_2.0.3       
    [10] timechange_0.2.0      evaluate_0.23         grid_4.3.2           
    [13] fastmap_1.1.1         rprojroot_2.0.4       jsonlite_1.8.8       
    [16] Matrix_1.6-1.1        zip_2.3.0             backports_1.4.1      
    [19] fansi_1.0.6           scales_1.3.0          microbenchmark_1.4.10
    [22] jquerylib_0.1.4       cli_3.6.2             rlang_1.1.2          
    [25] crayon_1.5.2          munsell_0.5.0         withr_2.5.2          
    [28] cachem_1.0.8          yaml_2.3.8            tools_4.3.2          
    [31] tzdb_0.4.0            colorspace_2.1-0      Deriv_4.1.3          
    [34] broom_1.0.5           vctrs_0.6.5           R6_2.5.1             
    [37] lifecycle_1.0.4       MASS_7.3-60           pkgconfig_2.0.3      
    [40] pillar_1.9.0          bslib_0.6.1           gtable_0.3.4         
    [43] glue_1.6.2            xfun_0.41             tidyselect_1.2.0     
    [46] rstudioapi_0.15.0     htmltools_0.5.7       compiler_4.3.2       

------------------------------------------------------------------------

# Cite R packages used

| Package     | Version | Citation                                                                                      |
|:------------|:--------|:----------------------------------------------------------------------------------------------|
| base        | 4.3.2   | R Core Team (2023)                                                                            |
| doBy        | 4.6.20  | Højsgaard and Halekoh (2023)                                                                  |
| grateful    | 0.2.4   | Francisco Rodriguez-Sanchez and Connor P. Jackson (2023)                                      |
| knitr       | 1.45    | Xie (2014); Xie (2015); Xie (2023)                                                            |
| R.methodsS3 | 1.8.2   | Bengtsson (2003a)                                                                             |
| R.oo        | 1.25.0  | Bengtsson (2003b)                                                                             |
| R.utils     | 2.12.3  | Bengtsson (2023)                                                                              |
| readODS     | 2.1.0   | Schutten et al. (2023)                                                                        |
| rmarkdown   | 2.25    | Xie, Allaire, and Grolemund (2018); Xie, Dervieux, and Riederer (2020); Allaire et al. (2023) |
| tidyverse   | 2.0.0   | Wickham et al. (2019)                                                                         |

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-rmarkdown2023" class="csl-entry">

Allaire, JJ, Yihui Xie, Christophe Dervieux, Jonathan McPherson, Javier
Luraschi, Kevin Ushey, Aron Atkins, et al. 2023.
*<span class="nocase">rmarkdown</span>: Dynamic Documents for r*.
<https://github.com/rstudio/rmarkdown>.

</div>

<div id="ref-RmethodsS3" class="csl-entry">

Bengtsson, Henrik. 2003a. “The <span class="nocase">R.oo</span>
Package - Object-Oriented Programming with References Using Standard R
Code.” In *Proceedings of the 3rd International Workshop on Distributed
Statistical Computing (DSC 2003)*, edited by Kurt Hornik, Friedrich
Leisch, and Achim Zeileis. Vienna, Austria:
https://www.r-project.org/conferences/DSC-2003/Proceedings/.
<https://www.r-project.org/conferences/DSC-2003/Proceedings/Bengtsson.pdf>.

</div>

<div id="ref-Roo" class="csl-entry">

———. 2003b. “The <span class="nocase">R.oo</span> Package -
Object-Oriented Programming with References Using Standard R Code.” In
*Proceedings of the 3rd International Workshop on Distributed
Statistical Computing (DSC 2003)*, edited by Kurt Hornik, Friedrich
Leisch, and Achim Zeileis. Vienna, Austria:
https://www.r-project.org/conferences/DSC-2003/Proceedings/.
<https://www.r-project.org/conferences/DSC-2003/Proceedings/Bengtsson.pdf>.

</div>

<div id="ref-Rutils" class="csl-entry">

———. 2023. *<span class="nocase">R.utils</span>: Various Programming
Utilities*. <https://CRAN.R-project.org/package=R.utils>.

</div>

<div id="ref-grateful" class="csl-entry">

Francisco Rodriguez-Sanchez, and Connor P. Jackson. 2023.
*<span class="nocase">grateful</span>: Facilitate Citation of r
Packages*. <https://pakillo.github.io/grateful/>.

</div>

<div id="ref-doBy" class="csl-entry">

Højsgaard, Søren, and Ulrich Halekoh. 2023.
*<span class="nocase">doBy</span>: Groupwise Statistics, LSmeans, Linear
Estimates, Utilities*.

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
