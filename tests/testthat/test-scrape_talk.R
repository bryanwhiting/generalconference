test_that("extract_metadata() works", {
  # This URL has p20 as first paragraph
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc, url)
  expect_equal(ans$author1, "By Elder David P. Homer")

  # 2021-08-25: pulled #p1 for metadata but author1 is not null
  # p_bodies for this starts at #p2, because #p1 is an #h1
  # all #h1s are getting skipped
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc, url)

  # New talk with p2 as first p
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/10/21eyring"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc, url)

})

test_that("extract_body_paragraphs_df() works", {
  # Old url
  url <- "https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness?lang=eng"
  rv_doc <- rvest::read_html(url)
  ans <- extract_body_paragraphs_df(rv_doc)

  expect_equal(sum(ans$section_num), 0, label = "Old talk has section numbers, shouldn't.")
  expect_equal(ans$p_id[1], "p2")

  # new URL: p1 is a header. has 4 sections
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
  rv_doc <- rvest::read_html(url)
  ans <- extract_body_paragraphs_df(rv_doc)
  expect_equal(max(ans$section_num), 4)
  expect_equal(ans$p_id[1], "p1")
  expect_equal(ans$is_header[1], T)

  # new URL: first paragraph is p20 (someone messed that up)
  # has multiple sections but they don't start with first p
  # sections have id=title, not id=p (unlike above url)
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  rv_doc <- rvest::read_html(url)
  ans <- extract_body_paragraphs_df(rv_doc)
  expect_equal(ans$p_id[1], 'p20')
  expect_equal(ans$is_header[1], FALSE)
  expect_equal(ans$p_id[2], 'p1')
  expect_equal(ans$p_id[4], 'title2')
  expect_equal(ans$is_header[4], TRUE)
  expect_equal(ans$p_id[7], 'title3')

  # new talk, p_id = p2
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/10/21eyring"
  rv_doc <- rvest::read_html(url)
  ans <- extract_body_paragraphs_df(rv_doc)
  expect_equal(ans$p_id[1], 'p2')

})


test_that("scrape_talk() 2021 works", {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2021/04/49nelson?lang=eng"

  df <- scrape_talk(url)
  expect_equal(df$title1, "Christ Is Risen; Faith in Him Will Move Mountains")
  expect_equal(df$author1, "By President Russell M. Nelson")
  expect_equal(nrow(df$paragraphs[[1]]), 33)
  expect_equal(df$paragraphs[[1]]$p_id[1], "p1")
})

test_that("scrape_talk() old talk: lacks #author1, lacks #kicker1", {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness"

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
