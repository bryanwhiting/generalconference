test_that("extract_metadata() works", {
  # This URL has p20 as first paragraph
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  html_doc <- rvest::read_html(url)
  ans <- extract_metadata(html_doc, url)
  expect_equal(ans$author1, "By Elder David P. Homer")

  # TODO: #h1
  # 2021-08-25: pulled #p1 for metadata but author1 is not null
  # p_bodies for this starts at #p2, because #p1 is an #h1
  # all #h1s are getting skipped
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
  html_doc <- rvest::read_html(url)
  ans <- extract_metadata(html_doc, url)

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


# talks that had #p1 as metadata
url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
talk <- scrape_talk(url)
talk$paragraphs

"https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
"https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
"https://www.churchofjesuschrist.org/study/general-conference/2019/10/21eyring"
"https://www.churchofjesuschrist.org/study/general-conference/2019/10/24nelson"
"https://www.churchofjesuschrist.org/study/general-conference/2019/10/43uchtdorf"


# Questions: why is it printing out URLs?
# which ones failed?
# TODO: rename talk_urls to talk_url_stub
# rename talk_urls to talk_path and session_url to session_path

x <- read_rds('data/sessions/201904.rds')
x %>%
  unnest(sessions) %>%
  unnest(talks) %>%
  view()

x <- x %>% unnest(sessions) %>% unnest(talks)
x %>% filter(str_detect(url, 'homer')) %>%
  unnest(paragraphs)
url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
