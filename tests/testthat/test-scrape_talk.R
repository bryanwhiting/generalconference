library(testthat)

test_that("scrape_talk() works", {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2021/04/49nelson?lang=eng"
  
  df <- scrape_talk(url)
  expect_equal(df$title1, "Christ Is Risen; Faith in Him Will Move Mountains")
  expect_equal(df$author1, "By President Russell M. Nelson")
  expect_equal(nrow(df$paragraphs[[1]]), 33)
})
