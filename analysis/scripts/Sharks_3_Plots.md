Plots for the dataset of DMTA on Devionan sharks
================
Ivan Calandra
2023-08-03 18:24:24 CEST

- [Goal of the script](#goal-of-the-script)
- [Load packages](#load-packages)
- [Read in data](#read-in-data)
  - [Get name and path of input file](#get-name-and-path-of-input-file)
  - [Read in Rbin file](#read-in-rbin-file)
- [Define variables](#define-variables)
- [Exclude surfaces with NMP ≥ 20%](#exclude-surfaces-with-nmp--20)
- [Plot each surface parameter in a
  boxplot](#plot-each-surface-parameter-in-a-boxplot)
  - [Pivot to longer format for facet
    plots](#pivot-to-longer-format-for-facet-plots)
  - [Plot](#plot)
  - [Save plot](#save-plot)
- [Plot anisotropy vs. complexity](#plot-anisotropy-vs-complexity)
  - [Plot](#plot-1)
  - [Save plot](#save-plot-1)
- [sessionInfo()](#sessioninfo)
- [Cite R packages used](#cite-r-packages-used)
  - [References](#references)

------------------------------------------------------------------------

# Goal of the script

The script plots all SSFA variables for the Devonian shark dataset.

``` r
dir_in  <- "analysis/derived_data"
dir_out <- "analysis/plots"
```

Input Rbin data file must be located in “~/analysis/derived_data”.  
Plots will be saved in “~/analysis/plots”.

The knit directory for this script is the project directory.

------------------------------------------------------------------------

# Load packages

``` r
pack_to_load <- c("ggplot2", "grateful", "knitr", "R.utils", "RColorBrewer", "rmarkdown", "tidyverse")
sapply(pack_to_load, library, character.only = TRUE, logical.return = TRUE)
```

         ggplot2     grateful        knitr      R.utils RColorBrewer    rmarkdown 
            TRUE         TRUE         TRUE         TRUE         TRUE         TRUE 
       tidyverse 
            TRUE 

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

# Define variables

Here we define which columns are used for the plots.

``` r
# Column to be used to group on the x-axis
x_var <- "Specimen"

# All numeric variables except NMP
y_var <- colnames(select(sharks, where(is.numeric)))[-1] 

# colors
grp_colors <- "Tooth"

# shapes
grp_shapes <- "NMP_cat"
```

The following variables will be used:

``` r
x_var
```

    [1] "Specimen"

``` r
y_var
```

     [1] "Sq"                       "Ssk"                     
     [3] "Sku"                      "Sp"                      
     [5] "Sv"                       "Sz"                      
     [7] "Sa"                       "Smr"                     
     [9] "Smc"                      "Sxp"                     
    [11] "Sal"                      "Str"                     
    [13] "Std"                      "Ssw"                     
    [15] "Sdq"                      "Sdr"                     
    [17] "Vm"                       "Vv"                      
    [19] "Vmp"                      "Vmc"                     
    [21] "Vvc"                      "Vvv"                     
    [23] "Maximum.depth.of.furrows" "Mean.depth.of.furrows"   
    [25] "Mean.density.of.furrows"  "First.direction"         
    [27] "Second.direction"         "Third.direction"         
    [29] "Texture.isotropy"         "epLsar"                  
    [31] "NewEplsar"                "Asfc"                    
    [33] "Smfc"                     "HAsfc9"                  
    [35] "HAsfc81"                 

``` r
grp_colors
```

    [1] "Tooth"

``` r
grp_shapes
```

    [1] "NMP_cat"

------------------------------------------------------------------------

# Exclude surfaces with NMP ≥ 20%

Surfaces with more than 20% NMP should not be analyzed.

``` r
sharks_nmp0_20 <- filter(sharks, NMP_cat != "≥20%")
sharks_nmp0_20$NMP_cat <- factor(sharks_nmp0_20$NMP_cat)
str(sharks_nmp0_20)
```

    'data.frame':   144 obs. of  42 variables:
     $ Specimen                : chr  "CC" "CC" "CC" "CC" ...
     $ Tooth                   : chr  "A" "A" "A" "A" ...
     $ Location                : chr  "loc1" "loc1" "loc1" "loc2" ...
     $ Objective               : chr  "100x" "100x" "100x" "100x" ...
     $ Measurement             : chr  "meas1" "meas2" "meas3" "meas1" ...
     $ NMP                     : num  3.03 3.05 3.34 9.84 9.78 ...
     $ NMP_cat                 : Ord.factor w/ 2 levels "<10%"<"10-20%": 1 1 1 1 1 1 2 2 2 1 ...
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

# Plot each surface parameter in a boxplot

## Pivot to longer format for facet plots

``` r
data_long <- select(sharks_nmp0_20, all_of(c(x_var, y_var, grp_colors, grp_shapes))) %>%
             pivot_longer(all_of(y_var), names_to = "parameter", values_to = "value")
str(data_long)
```

    tibble [5,040 × 5] (S3: tbl_df/tbl/data.frame)
     $ Specimen : chr [1:5040] "CC" "CC" "CC" "CC" ...
     $ Tooth    : chr [1:5040] "A" "A" "A" "A" ...
     $ NMP_cat  : Ord.factor w/ 2 levels "<10%"<"10-20%": 1 1 1 1 1 1 1 1 1 1 ...
     $ parameter: chr [1:5040] "Sq" "Ssk" "Sku" "Sp" ...
     $ value    : num [1:5040] 1.217 -0.332 2.531 2.739 3.419 ...

``` r
head(data_long)
```

    # A tibble: 6 × 5
      Specimen Tooth NMP_cat parameter  value
      <chr>    <chr> <ord>   <chr>      <dbl>
    1 CC       A     <10%    Sq         1.22 
    2 CC       A     <10%    Ssk       -0.332
    3 CC       A     <10%    Sku        2.53 
    4 CC       A     <10%    Sp         2.74 
    5 CC       A     <10%    Sv         3.42 
    6 CC       A     <10%    Sz         6.16 

## Plot

``` r
# set up plot
p_box <- ggplot(data_long, aes(x = .data[[x_var]], y = value)) +

         # Boxplots:
         # hide outliers (all points are shown with geom_point() below) 
         geom_boxplot(outlier.shape = NA) +
  
         # Points:
         # Add layers of shapes and colors for points 
         # Jitter points
         geom_point(mapping = aes(shape = .data[[grp_shapes]], color = .data[[grp_colors]]), position = "jitter", size = 2) +
  
         # Remove y-axis label
         labs(y = NULL) + 
  
         # Choose a light theme
         theme_classic() +
  
         # Wrap around parameters with free y-scales
         facet_wrap(~ parameter, scales = "free_y") +

         # The qualitative 'Set2' palette of RColorBrewer is colorblind friendly
         scale_color_brewer(palette = 'Set2')


# Print plot
print(p_box)
```

    Warning: Using shapes for an ordinal variable is not advised

    Warning: Removed 57 rows containing non-finite values (`stat_boxplot()`).

    Warning: Removed 57 rows containing missing values (`geom_point()`).

![](Sharks_3_Plots_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

## Save plot

``` r
ggsave(plot = p_box, filename = "DMTA-Ctenacanths_boxplots.pdf", 
       path = dir_out, width = 240, height = 190, units = "mm")
```

    Warning: Using shapes for an ordinal variable is not advised

    Warning: Removed 57 rows containing non-finite values (`stat_boxplot()`).

    Warning: Removed 57 rows containing missing values (`geom_point()`).

------------------------------------------------------------------------

# Plot anisotropy vs. complexity

## Plot

``` r
# set up plot
p_bi <- ggplot(data_nmp0_20, aes(x = Asfc, y = epLsar)) +
        
        # Scatterplot
        geom_point(mapping = aes_string(color = grp_colors, shape = grp_shapes), size = 4) +
  
        # Adjust axes labels
        labs(x = "Complexity (Asfc)", y = "Anisotropy (epLsar)") +
  
        # The qualitative 'Set2' palette of RColorBrewer is colorblind friendly
        scale_color_brewer(palette = 'Set2') +
  
        # Choose a light theme
        theme_classic()
```

    Error in eval(expr, envir, enclos): object 'data_nmp0_20' not found

``` r
# Print plot
print(p_bi)
```

    Error in eval(expr, envir, enclos): object 'p_bi' not found

## Save plot

``` r
ggsave(plot = p_bi, filename = "DMTA-Ctenacanths__epLsar-Asfc.pdf", 
       path = dir_out, width = 240, height = 190, units = "mm")
```

    Error in eval(expr, envir, enclos): object 'p_bi' not found

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
     [1] lubridate_1.9.2    forcats_1.0.0      stringr_1.5.0      dplyr_1.1.2       
     [5] purrr_1.0.1        readr_2.1.4        tidyr_1.3.0        tibble_3.2.1      
     [9] tidyverse_2.0.0    rmarkdown_2.23     RColorBrewer_1.1-3 R.utils_2.12.2    
    [13] R.oo_1.25.0        R.methodsS3_1.8.2  knitr_1.43         grateful_0.2.0    
    [17] ggplot2_3.4.2     

    loaded via a namespace (and not attached):
     [1] sass_0.4.7        utf8_1.2.3        generics_0.1.3    stringi_1.7.12   
     [5] hms_1.1.3         digest_0.6.33     magrittr_2.0.3    evaluate_0.21    
     [9] grid_4.3.1        timechange_0.2.0  fastmap_1.1.1     rprojroot_2.0.3  
    [13] jsonlite_1.8.7    fansi_1.0.4       scales_1.2.1      textshaping_0.3.6
    [17] jquerylib_0.1.4   cli_3.6.1         rlang_1.1.1       crayon_1.5.2     
    [21] munsell_0.5.0     withr_2.5.0       cachem_1.0.8      yaml_2.3.7       
    [25] tools_4.3.1       tzdb_0.4.0        colorspace_2.1-0  vctrs_0.6.3      
    [29] R6_2.5.1          lifecycle_1.0.3   ragg_1.2.5        pkgconfig_2.0.3  
    [33] pillar_1.9.0      bslib_0.5.0       gtable_0.3.3      glue_1.6.2       
    [37] systemfonts_1.0.4 xfun_0.39         tidyselect_1.2.0  highr_0.10       
    [41] rstudioapi_0.15.0 farver_2.1.1      htmltools_0.5.5   labeling_0.4.2   
    [45] compiler_4.3.1   

------------------------------------------------------------------------

# Cite R packages used

We used R version 4.3.1 (R Core Team 2023) and the following R packages:
grateful v. 0.2.0 (Francisco Rodríguez-Sánchez, Connor P. Jackson, and
Shaurita D. Hutchins 2023), knitr v. 1.43 (Xie 2014, 2015, 2023),
R.utils v. 2.12.2 (Bengtsson 2022), RColorBrewer v. 1.1.3 (Neuwirth
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

<div id="ref-RColorBrewer" class="csl-entry">

Neuwirth, Erich. 2022. *RColorBrewer: ColorBrewer Palettes*.
<https://CRAN.R-project.org/package=RColorBrewer>.

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
