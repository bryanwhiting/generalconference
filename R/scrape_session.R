#
# conference <- scrape_conference_urls(1971, 4)
# df <- conference %>%
#   unnest(sessions) %>%
#   unnest(session_talk_urls)
#
# url_root = "https://www.churchofjesuschrist.org/"
# urls <- file.path(url_root, df$talk_urls) %>%
#   str_replace(fixed('///'), '/')
# conference_talks <- map_df(urls, scrape_talk)
#
# library(furrr)
# library(tictoc)
# future::plan(multicore)
#
# tic('non-parallel')
# conference_talks <- map_df(urls, scrape_talk)
# toc('non-parallel')
# tic('parallel')
# conference_talks2 <- future_map_dfr(urls, scrape_talk)
# toc('parallel')
#
# saveRDS(conference_talks, file="data/197104_RDS")
# write_rds(conference_talks, file="data/197104_none", compress = 'none')
# write_rds(conference_talks, file="data/197104_gz", compress = 'gz')
# write_rds(conference_talks, file="data/197104_bz", compress = 'bz')
# write_rds(conference_talks, file="data/197104_xz", compress = 'xz')
#
# df_conference <- df %>%
#   bind_cols(conference_talks)
#
# write_rds(df_conference, file="data/197104_unnested_bz", compress = 'bz')
#
# df_conference %>%
#   group_nest(year, month) %>%
#   write_rds(file="data/197104_nested_bz", compress = 'bz')
#
# # do a double nest
# df_conference %>%
#   nest(talks = c(talk_urls, talk_session_id, url, title1, author1, author2, kicker1, paragraphs)) %>%
#   nest(sessions = c(session_name, session_id, session_url, talks)) %>%
#   write_rds(file="data/197104_nested2_bz", compress = 'bz2')
# # tODO: where's the paragraph_id??
# names(df_conference)








# SCRAPE
# TODO: create one scrape of all metadata (no talks)
#
url_root = "https://www.churchofjesuschrist.org/"


print_skipped_urls <- function(all_urls, exported_urls){
  skipped_urls <- all_urls[!(all_urls %in% exported_urls)]
  if(length(skipped_urls > 0)){
    message('The following urls were skipped:')
    message(paste(skipped_urls, collapse='\n'))
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
  mo_str = str_pad(month, width=2, pad="0")
  conference <- scrape_conference_urls(year, month)
  df_conference <- conference %>%
    unnest(sessions) %>%
    unnest(session_talk_urls)

  urls <- file.path(url_root, df_conference$talk_urls) %>%
    str_replace(fixed('///'), '/')

  conference_talks <- future_map_dfr(urls, scrape_talk)
  # Debug bad urls:
  # for(u in urls){
  #   print(u)
  #   x <- scrape_talk(u)
  # }
  # Print missing conference talks, if any. scrape_talk might skip some urls.
  exported_urls <- conference_talks$url %>%
    str_replace(url_root, '')
  all_urls <- df_conference$talk_urls
  print_skipped_urls(all_urls = all_urls, exported_urls = exported_urls)

  # Save out to disk
  df_conference %>%
    bind_cols(conference_talks) %>%
    nest(talks = c(talk_urls, talk_session_id, url, title1, author1, author2, kicker1, paragraphs)) %>%
    nest(sessions = c(session_name, session_id, session_url, talks)) %>%
    #'bz2' is one type of compression that seemed to perform the best
    write_rds(file=path, compress = 'bz2')
}

# scrapes the talk safely
scrape_conference_talks_possibly <- possibly(.f=scrape_conference_talks, otherwise=NULL)

scrape_all_conferences <- function(){
  # If there's an error, just skip

  tic('all')
  for (year in 2020:1971){
    tic(year)
    print(year)
    for (month in c(4, 10)){
      message(Sys.time(), "|   month:", month)
      tic(month)

      path = glue("data/sessions/{year}{mo_str}.rds")
      scrape_conference_talks_possibly(year=year, month=month, path=path)
      mo = str_pad(month, width=2, pad="0")

      yearmo = glue("{year}{mo}")
      path = glue('data/sessions/{yearmo}.rds')
      if (!file.exists(path)) {
        message("error on ", yearmo)
        write(file='data/sessions/_metadata', path, append=T)
      }
      toc(month)
    }
    toc(year)
  }
  toc('all')
}
