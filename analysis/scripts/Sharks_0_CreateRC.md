Create Research Compendium - DMTA on Devionan sharks
================
Ivan Calandra
2024-02-19 13:58:54 CET

- [Goal of the script](#goal-of-the-script)
- [Prerequisites](#prerequisites)
- [Preparations](#preparations)
- [Create the research compendium](#create-the-research-compendium)
  - [Load packages](#load-packages)
  - [Create compendium](#create-compendium)
  - [Create README.Rmd file](#create-readmermd-file)
  - [Create a folders](#create-a-folders)
  - [Delete file ‘NAMESPACE’](#delete-file-namespace)
- [Before running the analyses](#before-running-the-analyses)
- [After running the analyses](#after-running-the-analyses)
  - [DESCRIPTION](#description)
  - [renv](#renv)
- [sessionInfo()](#sessioninfo)
- [Cite R packages used](#cite-r-packages-used)
  - [References](#references)

------------------------------------------------------------------------

# Goal of the script

Create and set up a research compendium for the paper of DMTA on
Devionan sharks using the R package `rrtools`.  
For details on rrtools, see Ben Marwick’s [GitHub
repository](https://github.com/benmarwick/rrtools).

Note that this script is there only to show the steps taken to create
the research compendium and is not part of the analysis per se. For this
reason, most of the code is not evaluated
(`knitr::opts_chunk$set(eval=FALSE)`).

The knit directory for this script is the project directory.

------------------------------------------------------------------------

# Prerequisites

This script requires that you have a GitHub account and that you have
connected RStudio, Git and GitHub. For details on how to do it, check
[Happy Git](https://happygitwithr.com/).

------------------------------------------------------------------------

# Preparations

Before running this script, the first step is to [create a repository on
GitHub and to download it to
RStudio](https://happygitwithr.com/new-github-first.html). In this case,
the repository is called “DMTA.Ctenacanths”.  
Finally, open the RStudio project created.

------------------------------------------------------------------------

# Create the research compendium

## Load packages

``` r
library(grateful)
library(renv)
library(rrtools)
library(usethis)
```

## Create compendium

``` r
rrtools::use_compendium(getwd())
```

A new project has opened in a new session.  
Edit the fields “Title”, “Author” and “Description” in the `DESCRIPTION`
file.

## Create README.Rmd file

``` r
rrtools::use_readme_rmd()
```

Edit the `README.Rmd` file as needed.  
Make sure you render (knit) it to create the `README.md` file.

## Create a folders

Create a folder ‘analysis’ and subfolders to contain raw data, derived
data, plots, statistics and scripts. Also create a folder for the Python
analysis:

``` r
dir.create("analysis", showWarnings = FALSE)
dir.create("analysis/raw_data", showWarnings = FALSE)
dir.create("analysis/derived_data", showWarnings = FALSE)
dir.create("analysis/plots", showWarnings = FALSE)
dir.create("analysis/scripts", showWarnings = FALSE)
dir.create("analysis/stats", showWarnings = FALSE)
```

Note that the folders cannot be pushed to GitHub as long as they are
empty.

## Delete file ‘NAMESPACE’

``` r
file.remove("NAMESPACE")
```

------------------------------------------------------------------------

# Before running the analyses

After the creation of this research compendium, I have moved the raw,
input data files to `"~/analysis/raw_data"` (as read-only files) and the
R scripts to `"~/analysis/scripts"`.

------------------------------------------------------------------------

# After running the analyses

## DESCRIPTION

Run this command to add the dependencies to the DESCRIPTION file.

``` r
rrtools::add_dependencies_to_description()
```

## renv

Save the state of the project library using the `renv` package.

``` r
renv::init()
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
    [1] usethis_2.2.2  rrtools_0.1.5  renv_1.0.3     grateful_0.2.4

    loaded via a namespace (and not attached):
     [1] miniUI_0.1.1.1    jsonlite_1.8.8    compiler_4.3.2    crayon_1.5.2     
     [5] promises_1.2.1    Rcpp_1.0.11       git2r_0.33.0      stringr_1.5.1    
     [9] later_1.3.2       jquerylib_0.1.4   yaml_2.3.8        fastmap_1.1.1    
    [13] here_1.0.1        mime_0.12         R6_2.5.1          knitr_1.45       
    [17] htmlwidgets_1.6.4 profvis_0.3.8     rprojroot_2.0.4   shiny_1.8.0      
    [21] bslib_0.6.1       rlang_1.1.2       cachem_1.0.8      stringi_1.8.3    
    [25] httpuv_1.6.13     xfun_0.41         fs_1.6.3          sass_0.4.8       
    [29] pkgload_1.3.3     memoise_2.0.1     cli_3.6.2         magrittr_2.0.3   
    [33] digest_0.6.33     rstudioapi_0.15.0 xtable_1.8-4      clisymbols_1.2.0 
    [37] remotes_2.4.2.1   devtools_2.4.5    lifecycle_1.0.4   vctrs_0.6.5      
    [41] glue_1.6.2        evaluate_0.23     urlchecker_1.0.1  sessioninfo_1.2.2
    [45] pkgbuild_1.4.3    purrr_1.0.2       rmarkdown_2.25    tools_4.3.2      
    [49] ellipsis_0.3.2    htmltools_0.5.7  

------------------------------------------------------------------------

# Cite R packages used

| Package  | Version | Citation                                                 |
|:---------|:--------|:---------------------------------------------------------|
| base     | 4.3.2   | R Core Team (2023)                                       |
| grateful | 0.2.4   | Francisco Rodriguez-Sanchez and Connor P. Jackson (2023) |
| renv     | 1.0.3   | Ushey and Wickham (2023)                                 |
| rrtools  | 0.1.5   | Marwick (2019)                                           |
| usethis  | 2.2.2   | Wickham et al. (2023)                                    |

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-grateful" class="csl-entry">

Francisco Rodriguez-Sanchez, and Connor P. Jackson. 2023.
*<span class="nocase">grateful</span>: Facilitate Citation of r
Packages*. <https://pakillo.github.io/grateful/>.

</div>

<div id="ref-rrtools" class="csl-entry">

Marwick, Ben. 2019. *<span class="nocase">rrtools</span>: Creates a
Reproducible Research Compendium*.
<https://github.com/benmarwick/rrtools>.

</div>

<div id="ref-base" class="csl-entry">

R Core Team. 2023. *R: A Language and Environment for Statistical
Computing*. Vienna, Austria: R Foundation for Statistical Computing.
<https://www.R-project.org/>.

</div>

<div id="ref-renv" class="csl-entry">

Ushey, Kevin, and Hadley Wickham. 2023.
*<span class="nocase">renv</span>: Project Environments*.
<https://CRAN.R-project.org/package=renv>.

</div>

<div id="ref-usethis" class="csl-entry">

Wickham, Hadley, Jennifer Bryan, Malcolm Barrett, and Andy Teucher.
2023. *<span class="nocase">usethis</span>: Automate Package and Project
Setup*. <https://CRAN.R-project.org/package=usethis>.

</div>

</div>
