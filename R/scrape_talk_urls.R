# Generate urls
# scrape page for urls
# session urls
# Generate
paste(1971:2020)
url_root = "https://www.churchofjesuschrist.org/study/general-conference"
file.path(url_root, 1971, "04", "?lang=eng")
     
# output: dataframe with session url and nested df of all urls for that session
url = file.path(url_root, 1971, "04", "?lang=eng")
html_document <- rvest::read_html(url)
a <- html_document %>% html_element(".doc-map") 
a %>%
  html_nodes('a') %>%
  html_attr('href')



# Todo: fix the import and add unit tests
url <- 'https://www.churchofjesuschrist.org/study/general-conference/1971/04/out-of-the-darkness'
scrape_talk(url) %>%
  tidyr::unnest(paragraphs)
  