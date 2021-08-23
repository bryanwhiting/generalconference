test_that("parse_path_for_name() works", {
  path <- "/study/general-conference/2021/04/priesthood-session"
  expect_equal(parse_path_for_name(path), "Priesthood Session")

  path <- "/study/general-conference/2021/04/another-long-title-"
  expect_equal(parse_path_for_name(path), "Another Long Title")
})

test_that("parse_session_urls() works", {
  session_hrefs <- c(
    "/study/general-conference/2021/04/priesthood-session",
    "/study/general-conference/2021/04/31cook",
    "/study/general-conference/2021/04/32corbitt",
    "/study/general-conference/2021/04/33nielsen"
  )
  ans <- parse_session_urls(session_hrefs)
  expect_equal(ans$session_name, "Priesthood Session")
  expect_equal(ans$session_url, "/study/general-conference/2021/04/priesthood-session")
  expect_equal(nrow(ans$session_talk_urls[[1]]), 3)
})

test_that("scrape_conference_urls() integration test", {
  # tests all components of scrape_conference_url
  ans <- scrape_conference_urls(1971, 4)
  expect_equal(ans$year, 1971)
  expect_equal(ans$month, 4)

  # examine sessions
  ans2 <- ans %>% unnest(sessions)
  expect_equal(ans2$session_name[1], "Saturday Morning Session")
  expect_equal(ans2$session_name[7], "Tuesday Afternoon Session")

  # examine talk urls
  expect_equal(ans2$session_talk_urls[1][[1]]$talk_urls[4],
               "/study/general-conference/1971/04/life-is-eternal")
  expect_equal(nrow(ans2$session_talk_urls[1][[1]]), 4)
  expect_equal(nrow(ans2$session_talk_urls[5][[1]]), 7)
})
