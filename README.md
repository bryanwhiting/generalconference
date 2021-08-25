# generalconference

Scrape General Conference Talks using R



# Developer notes

Building a package: https://r-pkgs.org/vignettes.html, 
https://fanwangecon.github.io/R4Econ/support/development/fs_packaging.pdf

* devtools::create('generalconference')
* devtools::install()
* usethis::use_vignette('introduction')
* https://pkgdown.r-lib.org/

workflow: https://r-pkgs.org/whole-game.html

* usethis::use_r(name="new_func"): build functions in R and save
* usethis::use_test(name="new_func"): builds new test 
* usethis::use_package('xxxx'): Add new package to DESCRIPTION as necessary
* devtools::load_all()
* devtools::test()
* devtools::check(): checks package

Build documentation:

* Update _pkgdown.yml with documents
* covr::report()
* devtools::document() -> generates NAMESPACE from documentation
* devtools::run_examples()
* devtools::build_vignettes()
* devtools::build()
* pkgdown::build_site()

packages used:
* usethis::use_mit_license("My Name")
* usethis::use_package('dplyr')
* usethis::use_package('rvest')

Unit tests:
* use_test("scrape_talk") 


# Next steps:
- [ ] Build loop to extract all URLs from all sessions
- [ ] Build loop to extract all content from all URLs
- [ ] Refactor: rename scrape-talk-urls to scrape-conference-urls
- [ ] Have a separate script for "scrape" data and "process (loop scrapes)"
- [ ] Nest data
- [ ] Test out size of data saveRDS() (or use write_rds and set compression)
- [ ] Set up code coverage
- [ ] Set up github actions


x <- mtcars %>%
  select(mpg, disp, am, vs) %>%
  nest(data = c(vs, c(mpg, disp)))


