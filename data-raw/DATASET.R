## code to prepare `DATASET` dataset goes here

setwd("/home/rstudio/generalconference")
# one conference
library(tictoc)
library(readr)
library(generalconference)
year <- 2021
month <- 4
mo <- "04"
path <- glue("data/sessions/{year}{mo}.rds")
scrape_conference_talks(year = year, month = month, path = path)




# TODO: Add timeout
# https://stackoverflow.com/questions/51651465/how-to-use-withtimeout-function-to-interrupt-expression-if-it-takes-too-long
# for timeouts
# library(R.utils)
# tryCatch(
#   {
#     res <- withTimeout(
#       {
#         Sys.sleep(5)
#       },
#       timeout = 1
#     )
#   },
#   TimeoutException = function(ex) cat("Timed out\n")
# )

# scrapes the talk safely
scrape_conference_talks_possibly <- furrr::possibly(.f = scrape_conference_talks, otherwise = NULL)

scrape_all_conferences <- function() {
  # If there's an error, just skip
  end_yr <- 2020
  start_yr <- 2019

  tic("all")
  for (year in end_yr:start_yr) {
    tic(year)
    print(year)
    for (month in c(4, 10)) {
      message(Sys.time(), "|   month:", month)
      tic(month)

      mo <- str_pad(month, width = 2, pad = "0")
      path <- glue("data/sessions/{year}{mo}.rds")
      # df <- scrape_conference_talks_possibly(year = year, month = month, path = path)
      df <- scrape_conference_talks(
        year = year,
        month = month,
        path = path,
        loop_method = 1
      )

      #' bz2' is one type of compression that seemed to perform the best
      write_rds(df, file = path, compress = "bz2")
      cat("Saved out to:")
      print(path)

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
genconf <- list.files("data/sessions", full.names = T) %>%
  map(read_rds) %>%
  bind_rows()
usethis::use_data(genconf, overwrite = TRUE)
