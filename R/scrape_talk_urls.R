#' Parse path for name
#'
#' @param path file path with no extension
#'
#' @return Upper Case String
#' @export
#'
#' @examples
#' parse_path_for_name(path = "/path/to/hello-world-")
parse_path_for_name <- function(path) {
  basename(path) %>%
    str_replace_all(fixed("-"), " ") %>%
    trimws() %>%
    str_to_title()
}

#' Parse Session URLs
#' Take a vector of session hrefs, use the first value
#' as the session name, then the other values as the
#' session talks
#'
#' @param session_hrefs vector
#'
#' @return nested tibble
#' @export
parse_session_urls <- function(session_hrefs) {
  tibble(
    session_url = session_hrefs[1],
    talk_urls = session_hrefs[2:length(session_hrefs)],
  ) %>%
    mutate(
      session_name = parse_path_for_name(session_url),
      talk_session_id = row_number()
    ) %>%
    select(
      session_name, session_url, talk_urls, talk_session_id
    ) %>%
    nest(session_talk_urls = c(talk_urls, talk_session_id))
}

#' Scrape HTML doc map from Conference URL
#' Given a year and a month, pull the entire .doc-map class
#' object from the Conference URL. This will be parsed
#' by downstream objects
#'
#' @param year Year (integer)
#' @param month Month (integer)
#'
#' @return Rvest object
#' @export
#'
#' @examples
#' scrape_conference_html_doc_map(2017, 4)
#' scrape_conference_html_doc_map(1971, 10)
#' scrape_conference_html_doc_map(1985, 10)
scrape_conference_html_doc_map <- function(year, month) {
  # Generate the conference url
  url_root <- "https://www.churchofjesuschrist.org/study/general-conference"
  # convert 4 to "04"
  month <- str_pad(month, width = 2, pad = "0")
  url <- file.path(url_root, year, month, "?lang=eng")

  # scrape the conference doc map and return
  html_conference <- read_html(url) %>%
    html_element(".doc-map")
}

#' Extract Session hrefs
#'
#' @param html_docmap An rvest docmap scrape from
#' scrape_conference_html_doc_map()
#' @param session_id Integer for session you want to extract
#'
#' @return hrefs for the session, which includes the Session href in addition
#' to the talk refs.
#' @export
#'
#' @examples
#' scrape_conference_html_doc_map(2019, 4) %>%
#'   extract_session_hrefs(session_id = 1) %>%
#'   parse_session_urls()
extract_session_hrefs <- function(html_docmap, session_id) {
  html_docmap %>%
    html_element(glue("li:nth-child({session_id}) .doc-map")) %>%
    html_elements("a") %>%
    html_attr("href")
}

#' Main function to scrape all conference talk urls
#' For a given year-month conference, return a nested tibble of all sessions
#' with a tibble-column containing the dataframes
#'
#'
#' @param year
#' @param month
#'
#' @return tibble
#' @export
#'
#' @examples
#' scrape_conference_urls(2019, 10)
#' scrape_conference_urls(1971, 4)
scrape_conference_urls <- function(year, month) {
  html_conference_doc_map <- scrape_conference_html_doc_map(year, month)

  n_sessions <- html_conference_doc_map %>%
    html_elements(".label") %>%
    length()

  map_df(1:n_sessions, ~ {
    extract_session_hrefs(html_conference_doc_map, .x) %>%
      parse_session_urls()
  }) %>%
    mutate(
      year = year,
      month = month,
      session_id = row_number()
    ) %>%
    select(year, month, session_name, session_id, session_url, session_talk_urls) %>%
    nest(sessions = c(session_name, session_id, session_url, session_talk_urls))
}
