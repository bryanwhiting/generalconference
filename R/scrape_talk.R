#' Extract html document elements
#'
#' rvest::read_html("https://www.churchofjesuschrist.org/study/general-conference/1971/04/kingdom-of-god?lang=eng") %>% extract_element("#title1")
#'
#' @param html_document rvest::read_html() document
#' @param element class you want to extract (use Selector Gadget)
#'
#' @return dataframe
extract_element <- function(html_document, element) {
  html_document %>%
    html_element(element) %>%
    html_text2() %>%
    tibble() %>%
    setNames(element) # name the dataframe with the element content
}

#' Title
#'
#' @param rv_document
#'
#' @return
#' @export
#'
#' @examples
extract_body_paragraphs_df <- function(rv_doc) {
  # .body-block specifies the text of the talk
  # in older talks, it starts with #p2 as #p1 is the author
  # in some talks, #p20 is the first: "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  # html_body_paragraphs <- html_document %>%
  #   html_elements(".body-block p")
  #
  # # header is first paragraph, but also an h2
  # # See "https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
  # html_header_paragraphs <- html_document %>%
  #   html_elements(".body-block h2")
  # url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/04/28stevenson"
  # url <- "https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness?lang=eng"
  # url <- "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  # rv_document <- rvest::read_html(url)

  rv_paragraphs <- rv_doc %>%
    # Extract both headers and paragraphs out of body
    html_elements(".body-block h2, .body-block p")

  rv_paragraphs %>%
    map_df(~ c(paragraph = toString(.))) %>%
    mutate(
      p_id = html_attr(rv_paragraphs, "id"),
      is_header = str_detect(paragraph, "^\\<h2"),
      p_num = row_number(),
      section_num = cumsum(is_header),
      # strip out footnotes
      paragraph =
        str_replace_all(
          paragraph,
          pattern = c(
            "<sup.*</sup>" = "",
            "<.*?>" = "",
            "\n" = ""
          )
        ) %>%
          trimws()
    ) %>%
    select(section_num, p_num, p_id, is_header, paragraph)
}

extract_metadata <- function(rv_doc, url) {
  #' Extract title, author, and kicker from a url and return as a row in a
  #' dataframe.

  # the .body-block contains the speech text. But the #p anchors
  # can be wrong.
  # returns list of p1, p2, p3... for new talks and p2, p3, p4 for old talks
  p_bodies <- rv_doc %>%
    html_elements(".body-block p") %>%
    html_attr("id")

  # Explaining !("p1" %in% p_bodies):
  #  Sometimes, the first paragraph isn't p1
  #  e.g., "https://www.churchofjesuschrist.org/study/general-conference/2019/04/27homer"
  #  First paragraph is "p20", then 2nd is "p1".
  if (p_bodies[1] == "p1" | ("p1" %in% p_bodies)) {
    # In new talks, #p1 is the paragraph text
    elements <- c("#title1", "#author1", "#author2", "#kicker1")
    map_dfc(elements, ~ extract_element(html_document = rv_doc, element = .)) %>%
      rename_all(~ str_replace(., fixed("#"), "")) %>%
      return()
  } else {
    # In older talks, #p1 is the author block
    elements <- c("#title1", "#author1", "#author2", "#kicker1", "#p1")
    df <- map_dfc(elements, ~ extract_element(html_document = rv_doc, element = .)) %>%
      rename_all(~ str_replace(., fixed("#"), ""))

    if (is.na(df$author1)) {
      df$author1 <- df$p1
    } else {
      message("pulled #p1 for metadata but author1 is not null: ", url)
    }
    df %>%
      select(-p1) %>%
      return()
  }
}



#' Scrape general conference talk
#'
#' @param url general conference https
#' @return dataframe
#'
#' @export
scrape_talk <- function(url) {
  # TODO: figure out a way to link in footnotes
  # url =
  # url <- 'https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness'
  rv_doc <- rvest::read_html(url)

  df_metadata <- rv_doc %>%
    extract_metadata(., url = url) %>%
    mutate(url = url) %>%
    select(url, everything())

  # Get all paragraphs
  df_paragraphs <- extract_body_paragraphs(rv_doc)

  # store as a tibble of tibbles.
  # this allows you to have one row per talk.
  # You can unnest the "paragraphs" for analysis.
  df_talk <- tibble(
    df_metadata,
    paragraphs = list(df_paragraphs)
  )
  df_talk
}
