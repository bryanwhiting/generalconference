
<!-- README.md is generated from README.Rmd. Please edit that file -->

# generalconference

[General
Conference](https://www.churchofjesuschrist.org/study/general-conference?lang=eng)
is a semi-annual event where members of The Church of Jesus Christ of
Latter-day Saints gather to listen to church prophets, apostles, and
other leaders.

This package both scrapes General Conference talks and provides all
talks in a data package.

``` r
library(generalconference)
library(dplyr)
library(tidyr)
```

``` r
data("genconf")
head(genconf)
#> # A tibble: 6 × 3
#>    year month sessions        
#>   <dbl> <dbl> <list>          
#> 1  1971     4 <tibble [7 × 4]>
#> 2  1971    10 <tibble [7 × 4]>
#> 3  1972     4 <tibble [7 × 4]>
#> 4  1972    10 <tibble [7 × 4]>
#> 5  1973     4 <tibble [7 × 4]>
#> 6  1973    10 <tibble [7 × 4]>
```

``` r
genconf %>%
  unnest(sessions) %>%
  unnest(talks) %>%
  head()
#> # A tibble: 6 × 13
#>    year month session_name  session_id session_url   talk_urls   talk_session_id
#>   <dbl> <dbl> <chr>              <int> <chr>         <chr>                 <int>
#> 1  1971     4 Saturday Mor…          1 /study/gener… /study/gen…               1
#> 2  1971     4 Saturday Mor…          1 /study/gener… /study/gen…               2
#> 3  1971     4 Saturday Mor…          1 /study/gener… /study/gen…               3
#> 4  1971     4 Saturday Mor…          1 /study/gener… /study/gen…               4
#> 5  1971     4 Saturday Aft…          2 /study/gener… /study/gen…               1
#> 6  1971     4 Saturday Aft…          2 /study/gener… /study/gen…               2
#> # … with 6 more variables: url <chr>, title1 <chr>, author1 <chr>,
#> #   author2 <chr>, kicker1 <chr>, paragraphs <list>
```

See [Example
Analysis](https://bryanwhiting.github.io/generalconference/docs/articles/example-analysis.html)
for more examples on how to analyze the data.

See documentation for scrapers
