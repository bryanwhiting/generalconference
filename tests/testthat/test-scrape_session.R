test_that('print_skipped_urls() works', {
  all_urls <- c('a', 'b', 'c')
  exported_urls <- c('a')
  expect_message(print_skipped_urls(all_urls, exported_urls))

  # no skips, should return nothing
  # regexp=NA gives no error. https://stackoverflow.com/a/33638939
  all_urls <- c('a', 'b', 'c')
  exported_urls <- all_urls
  expect_message(print_skipped_urls(all_urls, exported_urls), regexp = NA)
})
