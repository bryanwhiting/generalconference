# generalconference

Scrape General Conference Talks using R



# Developer notes
Building a package: https://r-pkgs.org/vignettes.html
* devtools::create('generalconference')
* devtools::install()
* usethis::use_vignette('introduction')
* https://pkgdown.r-lib.org/

workflow: https://r-pkgs.org/whole-game.html

* usethis::use_r(name="new_func"): build functions in R and save
* usethis::use_test(name="new_func"): builds new test 
* devtools::load_all()
* devtools::build()
* pkgdown::build_site()
* devtools::check()

packages used:
* usethis::use_mit_license("My Name")
* usethis::use_package('dplyr')
* usethis::use_package('rvest')

Unit tests:
* use_test("scrape_talk") 

