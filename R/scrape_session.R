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
scrape_conference_talks <- function(year, month, path) {
  mo_str <- str_pad(month, width = 2, pad = "0")
  conference <- scrape_conference_urls(year, month)
  df_conference <- conference %>%
    unnest(sessions) %>%
    unnest(session_talk_urls)

  urls <- file.path(url_root, df_conference$talk_urls) %>%
    str_replace(fixed("///"), "/")

  # arbitrary flag to avoid commenting/uncommenting code
  # During debugging
  method = 2
  if (method == 1) {
    conference_talks <- future_map_dfr(urls, scrape_talk)
  } else if (method == 2) {
    conference_talks <- map_dfr(urls, scrape_talk)
  } else if (methods == 3) {
    # Debug bad urls, one by one:
    conference_talks <- tibble()
    for(u in urls){
      print(u)
      conference_talks <- bind_rows(conference_talks, scrape_talk(u))
    }
  }
  # Pring bad URLS
  conference_talks %>%

  conference_talks %>%
    filter(is.na(titles1)) %>%
    pull(url)

  # Print missing conference talks, if any. scrape_talk might skip some urls.
  exported_urls <- conference_talks$url %>%
    str_replace(url_root, "") %>%
    paste0("/", .)

  all_urls <- df_conference$talk_urls
  print_skipped_urls(all_urls = all_urls, exported_urls = exported_urls)

  # Save out to disk
  df_conference %>%
    bind_cols(conference_talks) %>%
    nest(talks = c(talk_urls, talk_session_id, url, title1, author1, author2, kicker1, paragraphs)) %>%
    nest(sessions = c(session_name, session_id, session_url, talks))
}

# scrapes the talk safely
scrape_conference_talks_possibly <- possibly(.f = scrape_conference_talks, otherwise = NULL)
