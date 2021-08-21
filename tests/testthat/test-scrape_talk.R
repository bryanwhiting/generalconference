test_that("scrape_talk() 2021 works", {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2021/04/49nelson?lang=eng"
  
  df <- scrape_talk(url)
  expect_equal(df$title1, "Christ Is Risen; Faith in Him Will Move Mountains")
  expect_equal(df$author1, "By President Russell M. Nelson")
  expect_equal(nrow(df$paragraphs[[1]]), 33)
  expect_equal(df$paragraphs[[1]]$p_id[1], "p1")
})

test_that("scrape_talk() old talk: lacks #author1, lacks #kicker1", {
  url <- 'https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness'
  
  df <- scrape_talk(url)
  expect_equal(df$title1, "Out of the Darkness")
  expect_equal(df$author1, "Joseph Fielding Smith")
  expect_equal(nrow(df$paragraphs[[1]]), 24)
  expect_equal(df$paragraphs[[1]]$p_id[1], "p2")
  
})

test_that("scrape_talk() old talk, has kicker, lacks author1", {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/1971/04/choose-you-this-day?lang=eng"
  df <- scrape_talk(url)
  expect_equal(df$title1, "“Choose You This Day”")
  expect_equal(df$author1, "N. Eldon Tanner")
  expect_equal(nrow(df$paragraphs[[1]]), 62)
  expect_equal(df$paragraphs[[1]]$p_id[1], "p2")
})