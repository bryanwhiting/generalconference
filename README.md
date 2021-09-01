
<!-- README.md is generated from README.Rmd. Please edit that file -->

# generalconference

[General
Conference](https://www.churchofjesuschrist.org/study/general-conference?lang=eng)
is a semi-annual event where members of The Church of Jesus Christ of
Latter-day Saints gather to listen to church prophets, apostles, and
other leaders.

This package both scrapes General Conference talks and provides all
talks in a data package for analysis in R.

## Install the package

``` r
# install.packages('devtools')
devtools::install_github("bryanwhiting/generalconference")
```

Load the package:

``` r
library(generalconference)
```

Load the General Conference corpus, which is a tibble with nested data
for each conference, session, talk, and paragraph.

``` r
data("genconf")
head(genconf)
#> # A tibble: 6 × 4
#>    year month date       sessions        
#>   <dbl> <dbl> <date>     <list>          
#> 1  2021     4 2021-04-01 <tibble [5 × 4]>
#> 2  2020    10 2020-10-01 <tibble [5 × 4]>
#> 3  2020     4 2020-04-01 <tibble [5 × 4]>
#> 4  2019    10 2019-10-01 <tibble [5 × 4]>
#> 5  2019     4 2019-04-01 <tibble [5 × 4]>
#> 6  2018    10 2018-10-01 <tibble [5 × 4]>
```

## Getting Started

Unnest it to analyze individual talks, which can be unnested further to
the paragraph level.

``` r
library(dplyr)
library(tidyr)
genconf %>%
  tidyr::unnest(sessions) %>%
  tidyr::unnest(talks) %>%
  head()
#> # A tibble: 6 × 14
#>    year month date       session_name   session_id session_url      talk_urls   
#>   <dbl> <dbl> <date>     <chr>               <int> <chr>            <chr>       
#> 1  2021     4 2021-04-01 Saturday Morn…          1 /study/general-… /study/gene…
#> 2  2021     4 2021-04-01 Saturday Morn…          1 /study/general-… /study/gene…
#> 3  2021     4 2021-04-01 Saturday Morn…          1 /study/general-… /study/gene…
#> 4  2021     4 2021-04-01 Saturday Morn…          1 /study/general-… /study/gene…
#> 5  2021     4 2021-04-01 Saturday Morn…          1 /study/general-… /study/gene…
#> 6  2021     4 2021-04-01 Saturday Morn…          1 /study/general-… /study/gene…
#> # … with 7 more variables: talk_session_id <int>, url <chr>, title1 <chr>,
#> #   author1 <chr>, author2 <chr>, kicker1 <chr>, paragraphs <list>
```

Analyze individual paragraphs that contain the word “faith”:

``` r
library(gt)
genconf %>%
  # unpack/unnest the dataframe, which is a tibble of lists
  tidyr::unnest(sessions) %>%
  tidyr::unnest(talks) %>%
  tidyr::unnest(paragraphs) %>%
  # extract just the date, title, author and paragraph
  # date, title, and author will be repeated fields, with paragraph unique
  select(date, title1, author1, paragraph) %>%
  # Filter to just the paragraphs that mention the word "faith"
  filter(stringr::str_detect(paragraph, "faith")) %>%
  # take top 5 records
  head(5) %>%
  # convert into a gt() table with row groups for date/title/author
  # (use row groups since these data are replicated by paragraph)
  group_by(date, title1, author1) %>%
  gt() %>%
  tab_options(
    row_group.background.color = 'lightgray'
  ) %>%
  tab_header(
    title='Paragraphs on Faith',
    subtitle='Grouped by talk'
  )
```

<div id="kjgmesdonl" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#kjgmesdonl .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#kjgmesdonl .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kjgmesdonl .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#kjgmesdonl .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#kjgmesdonl .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kjgmesdonl .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kjgmesdonl .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#kjgmesdonl .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#kjgmesdonl .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#kjgmesdonl .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#kjgmesdonl .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#kjgmesdonl .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #D3D3D3;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#kjgmesdonl .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #D3D3D3;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#kjgmesdonl .gt_from_md > :first-child {
  margin-top: 0;
}

#kjgmesdonl .gt_from_md > :last-child {
  margin-bottom: 0;
}

#kjgmesdonl .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#kjgmesdonl .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#kjgmesdonl .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kjgmesdonl .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#kjgmesdonl .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kjgmesdonl .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#kjgmesdonl .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#kjgmesdonl .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kjgmesdonl .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kjgmesdonl .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#kjgmesdonl .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kjgmesdonl .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#kjgmesdonl .gt_left {
  text-align: left;
}

#kjgmesdonl .gt_center {
  text-align: center;
}

#kjgmesdonl .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#kjgmesdonl .gt_font_normal {
  font-weight: normal;
}

#kjgmesdonl .gt_font_bold {
  font-weight: bold;
}

#kjgmesdonl .gt_font_italic {
  font-style: italic;
}

#kjgmesdonl .gt_super {
  font-size: 65%;
}

#kjgmesdonl .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  <thead class="gt_header">
    <tr>
      <th colspan="1" class="gt_heading gt_title gt_font_normal" style>Paragraphs on Faith</th>
    </tr>
    <tr>
      <th colspan="1" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>Grouped by talk</th>
    </tr>
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">paragraph</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <td colspan="1" class="gt_group_heading">2021-04-01 - God among Us - By Elder Dieter F. Uchtdorf</td>
    </tr>
    <tr><td class="gt_row gt_left">The doubting He would infuse with faith and courage to believe.</td></tr>
    <tr><td class="gt_row gt_left">He would recognize and honor honesty, humility, integrity, faithfulness, compassion, and charity.</td></tr>
    <tr><td class="gt_row gt_left">To you, my dear brothers and sisters, my dear friends, and to all who are searching for answers, truth, and happiness, I do offer the same counsel: keep searching with faith and patience.</td></tr>
    <tr class="gt_group_heading_row">
      <td colspan="1" class="gt_group_heading">2021-04-01 - Essential Conversations - By Joy D. Jones</td>
    </tr>
    <tr><td class="gt_row gt_left">Have faith in Christ, the Son of the living God.</td></tr>
    <tr><td class="gt_row gt_left">Elder D. Todd Christofferson said, “Certainly the adversary is pleased when parents neglect to teach and train their children to have faith in Christ and be spiritually born again.”</td></tr>
  </tbody>
  
  
</table>
</div>

-   See [Example Analysis](articles/example-analysis.html) for more
    examples on how to analyze the data.
-   See [genconf](reference/genconf.html) for a schema of the data.

See documentation for scrapers, if you need them. But you shouldn’t need
them since all the data is available.
