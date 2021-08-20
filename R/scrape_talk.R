#
# rvest: https://www.r-bloggers.com/2019/07/beautifulsoup-vs-rvest/
easypackages::libraries("rvest", "dplyr", "purrr", "testthat", 'stringr')
url <- "https://www.churchofjesuschrist.org/study/general-conference/2021/04/49nelson?lang=eng"

#' Title
#'
#' @param html_document 
#' @param element 
#'
#' @return
#' @export
#'
#' @examples
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

extract_metadata <- function(html_document) {
  #' Extract title, author, and kicker from a url and return as a row in a 
  #' dataframe.
  elements <- c("#title1", "#author1", "#author2", "#kicker1")

  map_dfc(elements, ~ extract_element(html_document = html_document, element = .x)) %>%
    rename_all(~ str_replace(., fixed('#'), ""))
}

scrape_talk <- function(url){
  html_document <- read_html(url)
  
  df_metadata <- html_document %>%
    extract_metadata() %>%
    mutate(url = url) %>%
    select(url, everything())
  
  df_paragraphs <- html_document %>%
    html_elements('.body-block p') %>% # toString()
    # could use html_text(), but I want to remove footnotes
    str_replace_all("<sup.*</sup>", "") %>%
    str_replace_all("<.*?>", "") %>%
    str_replace_all(fixed('\n'), "") %>%
    tibble() %>%
    setNames('text') %>%
    mutate(paragraph = row_number()) %>%
    select(paragraph, text)
  
  # store as a tibble of tibbles.
  # this allows you to have one row per talk.
  # You can unnest the "paragraphs" for analysis.
  df_talk <- tibble(
    df_metadata, 
    paragraphs = list(df_paragraphs)
  )
  df_talk
}



  

# Todo: figure out a way to link in footnotes