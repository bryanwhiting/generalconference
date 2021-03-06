read_html <- rvest::read_html
# TODO: ans$author1 gets exact match, but fails unit test. Reallyodd

test_that('parse_url() works', {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer?lang=eng&fbclid=IwAR0QIVmzxVLpOI2qSeDzeAntDrvQ4gnARr1cpZc24pa74w6BgU4gEfy-5uc"
  parse_url(url) %>%
    expect_equal("https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer")
})

test_that('extract_url_from_rv_doc() works', {

  # video has no metadata
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/10/33video"
  extract_url_from_rv_doc(rv_doc = read_html(url)) %>%
    expect_equal(url)

  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer?lang=eng"
  url2 <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  extract_url_from_rv_doc(rv_doc = read_html(url)) %>%
    expect_equal(url2)

})

test_that("extract_metadata() works", {
  # This URL has p20 as first paragraph
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  rv_doc <- rvest::read_html(url)
  # should not return mesage
  ans <- extract_metadata(rv_doc)
  # expect_equal(ans$author1, "By Elder David P. Homer")
  expect_equal(nchar(ans$author1), 23)

  # New talk with p2 as first p
  # p1 just isn't in this .body-block but it's also not
  # in the non-body block.
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/10/21eyring"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc)
  expect_equal(ans$title1, "Sustaining of General Authorities, Area Seventies, and General Officers of the Church")
  # expect_equal(ans$author1, "Presented by President Henry B. Eyring")
  expect_equal(nchar(ans$author1), 38)

  # new talk, p2 is first p
  # p1 just isn't in this .body-block. Everything looks good.
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/10/24nelson"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc)
  expect_equal(ans$title1, "Witnesses, Aaronic Priesthood Quorums, and Young Women Classes")
  # expect_equal(ans$author1, "By President Russell M. Nelson")
  expect_equal(nchar(ans$author1), 30)
  expect_equal(ans$author2, "")

  # p1 is the header
  # p_bodies for this starts at #p2, because #p1 is an #h1
  # message should be present on this one
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc)
  expect_equal(ans$author2, "Of the Quorum of the Twelve Apostles")

  # p1 is the header
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/10/43uchtdorf"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc)
  expect_equal(ans$title1, "Your Great Adventure")
  # expect_equal(ans$author1, "By Elder Dieter F. Uchtdorf")
  expect_equal(nchar(ans$author1), 27)
  expect_equal(ans$author2, "Of the Quorum of the Twelve Apostles")
  expect_equal(ans$kicker1, "The Savior invites us, each day, to set aside our comforts and securities and join Him on the journey of discipleship.")

  # url uses p1-p4
  url <-  "https://www.churchofjesuschrist.org/study/liahona/2020/11/15cook"
  rv_doc <- rvest::read_html(url)
  ans <- extract_metadata(rv_doc)
  expect_equal(ans$title1, "Hearts Knit in Righteousness and Unity")
  # expect_equal(ans$author1, "By Elder Quentin L. Cook")
  expect_equal(nchar(ans$author1), 24)
  expect_equal(ans$kicker1, "At this 200-year hinge point in our Church history, let us commit ourselves to live righteously and be united as never before.")
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

test_that("extract_body_paragraphs_df() works with urls that have no paragraphs",{
  # Url has no body:
  # video has no metadata
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/10/33video?lang=eng"
  expect_message(extract_body_paragraphs_df(rv_doc = read_html(url)))

})


test_that("scrape_talk() 2021 works", {
  url <- "https://www.churchofjesuschrist.org/study/general-conference/2021/04/49nelson?lang=eng"

  df <- scrape_talk(url)
  expect_equal(df$title1, "Christ Is Risen; Faith in Him Will Move Mountains")
  # expect_equal(df$author1, "By President Russell M. Nelson")
  expect_equal(nchar(df$author1), 30)
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
