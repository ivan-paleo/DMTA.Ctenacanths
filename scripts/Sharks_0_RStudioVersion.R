#written by Ivan Calandra, 2023-06-12

#Output current version of RStudio to a text file for reporting purposes.

vers <- as.character(RStudio.Version()$version)
writeLines(c(vers, "\n"), "scripts/Sharks_0_RStudioVersion.txt")
