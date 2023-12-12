
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DMTA.Ctenacanths

This repository contains the data and code for our paper:  
\> Greif M, Calandra I, Lautenschlager S, Kaiser T & Klug C (submitted).
*Feeding behaviour and diet in Devonian ctenacanth chondrichthyans using
tooth wear and Finite Element analysis*. Name of journal: TBA.
<https://doi.org/xxx/xxx>

# How to cite

Please cite this compendium as:  
\> Greif M, Calandra I, Lautenschlager S, Kaiser T & Klug C (2023).
Compendium of R code and data for *Feeding behaviour and diet in
Devonian ctenacanth chondrichthyans using tooth wear and Finite Element
analysis*. Accessed 12 Dec 2023. Online at <https://doi.org/xxx/xxx>

# Contents

This [README.md](/README.md) file has been created by rendering the
[README.Rmd](/README.Rmd) file.

The [DESCRIPTION](/DESCRIPTION) file contains information about the
version, author, license and packages. For details on the license, see
the [LICENSE](/LICENSE) file.

The [DMTA.Ctenacanths.Rproj](/DMTA.Ctenacanths.Rproj) file is the
RStudio project file.

The [analysis](/analysis) directory contains all files related to the R
analysis. It is composed of the following folders:

- [:file_folder: derived_data](/analysis/derived_data): output data
  generated during the analysis (script
  [Sharks_1_Import.Rmd](/analysis/scripts/Sharks_1_Import.Rmd)).  
- [:file_folder: plots](/analysis/plots): plots generated during the
  analyses (script
  [Sharks_3_Plots.Rmd](/analysis/scripts/Sharks_3_Plots.Rmd)).  
- [:file_folder: raw_data](/analysis/raw_data): input data used in the
  analyses (script
  [Sharks_1_Import.Rmd](/analysis/scripts/Sharks_1_Import.Rmd))).  
- [:file_folder: scripts](/analysis/scripts): scripts used to run the
  analyses. See below for details.  
- [:file_folder: stats](/analysis/stats): summary statistics generated
  during the analyses (script
  [Sharks_2_Summary-stats.Rmd](/analysis/scripts/Sharks_2_Summary-stats.Rmd)).

The [scripts](/analysis/scripts) directory contains the following files:

- [Sharks_0_CreateRC.Rmd](/analysis/scripts/Sharks_0_CreateRC.Rmd):
  script used to create this research compendium - it is not part of the
  analysis *per se* and is not meant to be run again. Rendered to
  [Sharks_0_CreateRC.html](/analysis/scripts/Sharks_0_CreateRC.html) and
  [Sharks_0_CreateRC.md](/analysis/scripts/Sharks_0_CreateRC.md). The
  references are exported to a BIB file
  ([Sharks_0_CreateRC.bib](/analysis/scripts/Sharks_0_CreateRC.bib)).  
- [Sharks_1_Import.Rmd](/analysis/scripts/Sharks_1_Import.Rmd): script
  to import the raw, input data. Rendered to
  [Sharks_1_Import.md](/analysis/scripts/Sharks_1_Import.md) and
  [Sharks_1_Import.html](/analysis/scripts/Sharks_1_Import.html). The
  references are exported to a BIB file
  ([Sharks_1_Import.bib](/analysis/scripts/Sharks_1_Import.bib)).  
- [Sharks_2_Summary-stats.Rmd](/analysis/scripts/Sharks_2_Summary-stats.Rmd):
  script to compute group-wise summary statistics. Rendered to
  [Sharks_2_Summary-stats.md](/analysis/scripts/Sharks_2_Summary-stats.md)
  and
  [Sharks_2_Summary-stats.html](/analysis/scripts/Sharks_2_Summary-stats.html).
  The references are exported to a BIB file
  ([Sharks_2_Summary-stats.bib](/analysis/scripts/Sharks_2_Summary-stats.bib)).  
- [Sharks_3_Plots.Rmd](/analysis/scripts/Sharks_3_Plots.Rmd): script to
  produce plots for each SSFA variable. Rendered to
  [Sharks_3_Plots.md](/analysis/scripts/Sharks_3_Plots.md) and
  [Sharks_3_Plots.html](/analysis/scripts/Sharks_3_Plots.html). The
  references are exported to a BIB file
  ([Sharks_3_Plots.bib](/analysis/scripts/Sharks_3_Plots.bib)).  
- [Sharks_3_Plots_files](/analysis/scripts/Sharks_3_Plots_files/figure-gfm/):
  contains PNG files of the plots; used in the
  [Sharks_3_Plots.md](/analysis/scripts/Sharks_3_Plots.md) file.

Note that the HTML files are not rendered nicely on GitHub; you need to
download them and open them with your browser. Use the MD files to view
on GitHub. However, MD files do not have all functionalities of HTML
files (numbered sections, floating table of content). I therefore
recommend using the HTML files.  
To download an HTML file from GitHub, first display the “raw” file and
then save it as HTML.

Alternatively, use [GitHub & BitBucket HTML
Preview](https://htmlpreview.github.io/) to render it directly.  
Here are direct links to display the files directly in your browser:

- [Sharks_0_CreateRC.html](http://htmlpreview.github.io/?https://github.com/ivan-paleo/DMTA.Ctenacanths/blob/main/analysis/scripts/Sharks_0_CreateRC.html)
- [Sharks_1_Import.html](http://htmlpreview.github.io/?https://github.com/ivan-paleo/DMTA.Ctenacanths/blob/main/analysis/scripts/Sharks_1_Import.html)  
- [Sharks_2_Summary-stats.html](http://htmlpreview.github.io/?https://github.com/ivan-paleo/DMTA.Ctenacanths/blob/main/analysis/scripts/Sharks_2_Summary-stats.html)  
- [Sharks_3_Plots.html](http://htmlpreview.github.io/?https://github.com/ivan-paleo/DMTA.Ctenacanths/blob/main/analysis/scripts/Sharks_3_Plots.html)

See the section [Contributions](#contributions) for details on the
[CONDUCT.md](/CONDUCT.md) and [CONTRIBUTING.md](CONTRIBUTING.md) files.

# How to run in your browser or download and run locally

This research compendium has been developed using the statistical
programming languages R. To work with the compendium, you will need to
install on your computer the [R software](https://cloud.r-project.org/)
and [RStudio Desktop](https://rstudio.com/products/rstudio/download/).

To work locally with the R analysis, either from the ZIP archive or from
cloning the GitHub repository to your computer:

- open the [DMTA.Ctenacanths.Rproj](/DMTA.Ctenacanths.Rproj) file in
  RStudio; this takes some time the first time.  
- run `renv::status()` and then `renv::restore()` to restore the state
  of your project from [renv.lock](/renv.lock). Make sure that the
  package `devtools` is installed to be able to install packages from
  source.

Using the package `renv` implies that installing, removing and updating
packages is done within the project. In other words, all the packages
that you install/update while in a project using `renv` will not be
available in any other project. If you want to globally
install/remove/update packages, make sure you close the project first.

You can also download the compendium as [a ZIP
archive](https://github.com/ivan-paleo/DMTA.Ctenacanths/archive/main.zip).  
Alternatively, if you use GitHub, you can [fork and
clone](https://happygitwithr.com/fork-and-clone.html) the repository to
your account. See also the [CONTRIBUTING.md](CONTRIBUTING.md) file.

# License

[![CC BY-NC-SA
4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

This work is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

See also [License file](LICENSE) in the repository.

Author: Ivan Calandra

[![CC BY-NC-SA
4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

# Contributions

We welcome contributions from everyone. Before you get started, please
see our [contributor guidelines](CONTRIBUTING.md). Please note that this
project is released with a [Contributor Code of Conduct](CONDUCT.md). By
participating in this project you agree to abide by its terms.

# References

Soler S. 2022.cc-licenses: Creative Commons Licenses for GitHub
Projects. Available at <https://github.com/santisoler/cc-licenses>
(accessed September 27, 2022)
