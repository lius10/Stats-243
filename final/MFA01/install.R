#install.packages(c("devtools", "roxygen2", "testthat", "knitr"))

#setwd('E:/Stats-243/final/')
setwd('/Users/Shiying/Dropbox/BERKELEY_study/2016_Fall/02_STAT243/243_proj/Stats-243/final')

library(devtools)

pkg <- 'MFA01'

devtools::document(pkg = pkg)
devtools::check_man(pkg = pkg)
devtools::test(pkg = pkg)
devtools::build_vignettes(pkg = pkg)
devtools::build(pkg = pkg)
devtools::install(pkg = pkg)

library(MFA01)

# a <- MFA()
# a