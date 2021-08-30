## code to prepare `DATASET` dataset goes here

setwd('/home/rstudio/generalconference')
# one conference
library(generalconference)
year = 2021
month = 4
mo_str = "04"
path <- glue("data/sessions/{year}{mo_str}.rds")
scrape_conference_talks(year = year, month = month, path = path)


scrape_all_conferences <- function() {
  # If there's an error, just skip

  tic("all")
  for (year in 2020:1971) {
    tic(year)
    print(year)
    for (month in c(4, 10)) {
      message(Sys.time(), "|   month:", month)
      tic(month)

      path <- glue("data/sessions/{year}{mo_str}.rds")
      df <- scrape_conference_talks_possibly(year = year, month = month, path = path)
      mo <- str_pad(month, width = 2, pad = "0")

      #' bz2' is one type of compression that seemed to perform the best
      write_rds(df, file = path, compress = "bz2")
      cat("Saved out to:")
      print(path)

      yearmo <- glue("{year}{mo}")
      path <- glue("data/sessions/{yearmo}.rds")
      if (!file.exists(path)) {
        message("error on ", yearmo)
        write(file = "data/sessions/_metadata", path, append = T)
      }
      toc(month)
    }
    toc(year)
  }
  toc("all")
}
scrape_all_conferences()

# Join all conferences
# TODO: join the conferences


usethis::use_data(DATASET, overwrite = TRUE)


