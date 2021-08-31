#' General Conference Data
#'
#' A dataset containing all general conference talks back to 1971.
#'
#' @format genconf: A 4-level nested data frame with nestings for conference, session, talk, and paragraph.
#' \enumerate{
#' \item \strong{genconf} A data frame with one row per conference (year + month)
#' \describe{
#'   \item{year}{Session year}
#'   \item{month}{Session month}
#'   \item{sessions}{List dataframe with one row per session.}
#' }
#'
#' \item \strong{sessions} A data frame one row per session (Saturday AM, PM, etc.)
#' \describe{
#'   \item{session_name}{individual timepoint}
#'   \item{session_id}{mean value including imputed values}
#'   \item{session_url}{Suffix URL path to session (not full url))}
#'   \item{talks}{List of dataframes, one row per talk in that session}
#' }
#'
#'
#
#' \item \strong{talks} A data frame one row per talk
#' \describe{
#'   \item{talk_urls}{Stub urls for talk.}
#'   \item{talk_session_id}{Talk index within session}
#'   \item{url}{Full url path to talk.}
#'   \item{title1}{Title.}
#'   \item{author1}{Author Name (typically, might be missing)}
#'   \item{author2}{Author Role (typically, might be missing)}
#'   \item{kicker1}{Talk kicker}
#'   \item{paragraphs}{List of dataframes, one row per talk in that session}
#' }
#'
#' \item \strong{paragraphs} A data frame one row per paragraph in talk
#' \describe{
#'   \item{section_num}{If talk has sections, this would be the section number. Newer talks are more likely to have sections.}
#'   \item{p_num}{Paragraph number}
#'   \item{p_id}{Paragraph html tag (can be used to generate a url deep link). Might not be in order with p_num due to edge-case talks that use #p1-#p4 for title, author, kicker, etc.}
#'   \item{is_header}{If a talk contains sections, those sections have headers. Header content will be a few words.}
#'   \item{paragraph}{Text of talk. <sup></sup> html tags (superscripts/footnotes) have been stripped out.}
#' }
#' }
#' @source \url{https://www.churchofjesuschrist.org/study/general-conference}
# genconf %>% select(sessions) %>% unnest(sessions) %>% select(talks) %>% unnest(talks) %>% select(paragraphs) %>% unnest(paragraphs)
# https://stackoverflow.com/questions/38095578/documenting-a-list-of-data-frames-with-roxygen2
"genconf"
