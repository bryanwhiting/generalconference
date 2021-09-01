
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Developer notes

If you’re new to package development, this could be helpful to read.

# Initializing a package

-   <https://r-pkgs.org>
-   <https://fanwangecon.github.io/R4Econ/support/development/fs_packaging.pdf>
-   <https://pkgdown.r-lib.org/>

Starting a new package/one-time commands.

``` r
devtools::create('generalconference')
devtools::install()
usethis::use_mit_license("Bryan Whiting")
usethis::use_github()
usethis::use_github_links()
# specify packages you want to use
usethis::use_package('dplyr')
usethis::use_package('rvest')
# create files:
usethis::use_testthat()
usethis::use_r('newscript')
usethis::use_test()
# builds data-raw/ folder
use_this::use_data_raw() 
```

# Workflow

-   Read: <https://r-pkgs.org/whole-game.html>

``` r
# build functions in R and save, builds a test file
usethis::use_r(name="new_func")
usethis::use_test()

# Add new package to DESCRIPTION as necessary
usethis::use_package('xxxx'): 

# Once function is written, load it. You'll run `load_all()` multiple times.
devtools::load_all()
devtools::test()
devtools::check()   # checks package
```

# Build documentation

-   First, update `_pkgdown.yml` with documents
-   Second, run the following steps

``` r
# Add new documentation
usethis::use_vignette('introduction') # add a vignette

# (optional, one-off steps) Build individual files
devtools::run_examples()    # builds examples and vignettes
devtools::build_vignettes() #
pkgdown::build_articles()   # 
pkgdown::build_reference()  # edit reference in _pkgdown.yml reference: section

# Prepare the package
devtools::document()   # generates NAMESPACE from documentation. Exports functions.
covr::report()         # run the coverage test
devtools::test()       # run unit tests
devtools::check()      # check the package
devtools::build()      # build the package
pkgdown::build_site()  # Build the r package documentation
```

# Nested data

The data are nested to minimize redundancy, but they can easily be
unnested.

Example of nested data:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
mtcars %>%
  select(mpg, disp, am, vs) %>%
  tidyr::nest(data = c(vs, c(mpg, disp)))
#> # A tibble: 2 × 2
#>      am data             
#>   <dbl> <list>           
#> 1     1 <tibble [13 × 3]>
#> 2     0 <tibble [19 × 3]>
```

# Docker

All the packages and command line tools are available using the docker
container below.

``` bash
docker pull bryanwhiting/r_env:latest
```

# Github API

Github api is easy to manage issues.

``` bash
gh issue create
gh issue create --title "Some title of a new bug"
gh issue create --label "bug"
gh issue list
gh issue view 4 
# Todo: parse this and re-submit
gh issue view 4 --json body
```
