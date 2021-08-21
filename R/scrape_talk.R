#' Extract html document elements
#'
#' @param html_document
#' @param element
#'
#' @return dataframe
#'
#' @examples
#'
#' extract_metadata("#title1")
#'
#' html_document %>%
#'   html_element("#title1") %>%
#'   html_text2()
extract_element <- function(html_document, element) {
  #' extract a single element
  #'
  #' html_document %>% html_element("#title1") %>% html_text2()
  #'
  #' or
  #'
  #' extract_metadata('#title1')

  html_document %>%
    html_element(element) %>%
    html_text2() %>%
    tibble() %>%
    setNames(element) # name the dataframe with the element content
}

extract_metadata <- function(html_document, url) {
  #' Extract title, author, and kicker from a url and return as a row in a
  #' dataframe.
  
  # the .body-block contains the speech text. But the #p anchors
  # can be wrong.
  # returns list of p1, p2, p3... for new talks and p2, p3, p4 for old talks
  p_bodies <- html_document %>%
    html_elements(".body-block p") %>%
    html_attr('id')
  
  if (p_bodies[1] == "p1") {
    # In new talks, #p1 is the paragraph text
    elements <- c("#title1", "#author1", "#author2", "#kicker1")
    map_dfc(elements, ~ extract_element(html_document = html_document, element = .)) %>%
      rename_all(~ str_replace(., fixed("#"), "")) %>%
      return()
  } else {
    # In older talks, #p1 is the author block
    elements <- c("#title1", "#author1", "#author2", "#kicker1", "#p1")
    df <- map_dfc(elements, ~ extract_element(html_document = html_document, element = .)) %>%
      rename_all(~ str_replace(., fixed("#"), ""))
    
    if (is.na(df$author1)) {
      df$author1 <- df$p1
    } else {
      warning('pulled #p1 for metadata but author1 is not null')
      print(url)
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
  html_document <- rvest::read_html(url)

  df_metadata <- html_document %>%
    extract_metadata(., url=url) %>%
    mutate(url = url) %>%
    select(url, everything())

  # .body-block specifies the text of the talk
  # in older talks, it starts with #p2 as #p1 is the author
  html_paragraphs <- html_document %>%
    html_elements(".body-block p") 
  
  # storing the paragraph IDs to make url linking to quotes
  # more
  p_ids <- html_paragraphs %>%
    html_attr('id')
  
  df_paragraphs <- html_paragraphs %>%
    map_df(~ c(text = toString(.))) %>% 
    mutate(
      text =
        str_replace_all(text,
          pattern = c(
            "<sup.*</sup>" = "",
            "<.*?>" = "",
            "\n" = ""
          )
        )
    ) %>%
    mutate(
      paragraph = row_number(),
      p_id = p_ids) %>%
    select(paragraph, text, p_id)

  # store as a tibble of tibbles.
  # this allows you to have one row per talk.
  # You can unnest the "paragraphs" for analysis.
  df_talk <- tibble(
    df_metadata,
    paragraphs = list(df_paragraphs)
  )
  df_talk
}
