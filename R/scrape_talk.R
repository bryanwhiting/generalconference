#' Scrape an individual General Conference URL
#'
#' @description
#' Helps scrape a talk
#'
#' @details
#' See unit tests for edge case urls.


#' Simple string extractor. Removes ?lang=eng and other stuff
#'
#' @param url raw url
#'
#' @return string
parse_url <- function(url){
  str_match(url, '^(.*)\\?')[2]
}

#' Extract url from rv_doc
#'
#' @param rv_doc rvest::read_html() object
#'
#' @return string
extract_url_from_rv_doc <- function(rv_doc) {
  meta <- rv_doc %>%
    html_elements("head") %>%
    html_elements("meta")

  property <- meta %>%
    html_attr("property")
  idx_url <- which(property == "og:url")
  meta %>%
    html_attr("content") %>%
    .[[idx_url]] %>%
    parse_url()
}

#' Extract html document elements
#'
#' rvest::read_html("https://www.churchofjesuschrist.org/study/general-conference/1971/04/kingdom-of-god?lang=eng") %>% extract_element("#title1")
#'
#' @param rv_doc rvest::read_html() document
#' @param element class you want to extract (use Selector Gadget)
#'
#' @return dataframe
extract_element <- function(rv_doc, element) {
  # print(element)
  rv_doc %>%
    html_element(element) %>%
    html_text2() %>%
    tibble() %>%
    setNames(element) # name the dataframe with the element content
}

#' Produce paragraphs
#'
#' @param rv_doc rvest::read_html() document
#'
#' @return dataframe with paragraphs
#' @export
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
  # rv_doc <- rvest::read_html(url)

  rv_paragraphs <- rv_doc %>%
    # Extract both headers and paragraphs out of body
    html_elements(".body-block h2, .body-block p")

  if (length(rv_paragraphs) == 0) {
    url <- extract_url_from_rv_doc(rv_doc)
    msg <- glue("URL has no paragraphs.Perhaps add to scrape_talk() banned_urls?: [{url}]")
    message(msg)
    # stops quietly?: https://stackoverflow.com/a/42945293
    return()
  }
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

extract_metadata <- function(rv_doc){
  # url missing header
  # url <- "https://www.churchofjesuschrist.org/study/general-conference/2020/10/32craven"
  # url <- "https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness?lang=eng"
  # rv_doc <- read_html(url)

  get_text <- function(x){
    x %>%
      xml_contents() %>%
      toString()
  }
  # TODO: Fix header import.
  title1 <- rv_doc %>%
    html_elements(".body") %>%
    html_elements('header') %>%
    html_elements('h1')  %>%
    get_text()

  byline_str <- rv_doc %>% html_elements('.byline') %>% get_text()
  if(str_detect(byline_str, "author-name")){
    author1 <- rv_doc %>%
      html_elements(".author-name") %>%
      get_text()
    author2 <- rv_doc %>%
      html_elements(".author-role") %>%
      get_text()
  } else {
    author1 <- rv_doc %>%
      html_elements('.byline') %>%
      html_elements('p') %>%
      get_text()
    author2 <- ""
  }

  kicker1 <- rv_doc %>%
    html_elements(".kicker") %>%
    get_text()

  tibble(
    title1,
    author1,
    author2,
    kicker1
  )
}

#' Scrape general conference talk
#'
#' @param url general conference https
#' @return dataframe
#'
#' @export
scrape_talk <- function(url) {
  # TODO: figure out a way to link in footnotes
  # url <- 'https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness'
  banned_urls <- c(
    # TODO: add bad urls we skip over
    # REASON: is a video with no paragraphs
    "https://www.churchofjesuschrist.org/study/general-conference/2020/10/33video"
  )
  if (url %in% banned_urls) {
    return()
  }

  rv_doc <- rvest::read_html(url)

  df_metadata <- rv_doc %>%
    extract_metadata() %>%
    mutate(url = url) %>%
    select(url, everything())

  # Get all paragraphs
  df_paragraphs <- extract_body_paragraphs_df(rv_doc)

  # store as a tibble of tibbles.
  # this allows you to have one row per talk.
  # You can unnest the "paragraphs" for analysis.
  df_talk <- tibble(
    df_metadata,
    paragraphs = list(df_paragraphs)
  )
  df_talk
}
