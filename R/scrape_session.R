#
url_root <- "https://www.churchofjesuschrist.org/"

print_skipped_urls <- function(all_urls, exported_urls) {
  skipped_urls <- all_urls[!(all_urls %in% exported_urls)]
  if (length(skipped_urls > 0)) {
    message("The following urls were skipped:")
    message(paste(skipped_urls, collapse = "\n"))
  }
}

#' Scrapes all conference talks for a sessions
#'
#' For one-off sessions or debugging, see new-sessions.Rmd.
#'
#' @param year Year
#' @param month Month
#'
#' @return Writes out session to /data/sessions/<year><month>.rds
#' @export
scrape_conference_talks <- function(year, month, path, loop_method = 1) {
  mo_str <- str_pad(month, width = 2, pad = "0")

  conference <- scrape_conference_urls(year, month)
  df_conference <- conference %>%
    unnest(sessions) %>%
    unnest(session_talk_urls)

  urls <- file.path(url_root, df_conference$talk_urls) %>%
    str_replace(fixed("///"), "/")

  # arbitrary flag to avoid commenting/uncommenting code
  # During debugging
  # loop_method = 2
  if (loop_method == 1) {
    conference_talks <- future_map_dfr(urls, scrape_talk)
  } else if (loop_method == 2) {
    conference_talks <- map_dfr(urls, scrape_talk)
  } else if (loop_method == 3) {
    # Slowest, Debug bad urls, one by one:
    conference_talks <- tibble()
    for(u in urls){
      print(u)
      conference_talks <- bind_rows(conference_talks, scrape_talk(u))
    }
  }
  # Print bad URLS
  urls_no_title <- conference_talks %>%
    filter(is.na(title1)) %>%
    pull(url)

  urls_no_author <- conference_talks %>%
    filter(is.na(author1)) %>%
    pull(url)
  if (length(urls_no_title) > 0) {
    message('Urls with no title:')
    print(urls_no_title)
  }
  if (length(urls_no_author) > 0) {
    message('Urls with no author:')
    print(urls_no_author)
  }

  # Print missing conference talks, if any. scrape_talk might skip some urls.
  exported_urls <- conference_talks$url %>%
    str_replace(url_root, "") %>%
    paste0("/", .)

  all_urls <- df_conference$talk_urls
  print_skipped_urls(all_urls = all_urls, exported_urls = exported_urls)

  # Save out to disk
  url_root2 <- "https://www.churchofjesuschrist.org" # no trailing /
  df_conference %>%
    mutate(url = paste0(url_root2, talk_urls)) %>%
    left_join(conference_talks, by='url') %>%
    nest(talks = c(talk_urls, talk_session_id, url, title1, author1, author2, kicker1, paragraphs)) %>%
    nest(sessions = c(session_name, session_id, session_url, talks))
}
