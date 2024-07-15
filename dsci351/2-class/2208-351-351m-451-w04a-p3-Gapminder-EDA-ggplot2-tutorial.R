#' ---
#' author: "Jenny Bryan, modified by Roger French"
#' title: 2008-351-351m-451-w03a-p-Gapminder-EDA-ggplot2-tutorial.R
#' date: "`r format(Sys.time(), '%d %B, %Y')`"
#' output: pdf_document
#' ---


library(knitr)
opts_chunk$set(fig.path = 'figs/bryan/scatterplot-', 
               fig.width = 5, # the width for plots created by code chunk
               fig.height = 4, # the height for plots created by code chunk
               fig.align = 'center', # how to align graphics. 'left', 'right', 'center'
               dpi = 150, 
               echo = TRUE, # if FALSE knitr won't display code in chunk above it's results
               error = TRUE) # report errors

#' Note: this report is made by rendering an R script. So the narrative is very
#' minimal.

#==================================================================
#  Scatterplot 
#==================================================================

  library(tibble)
  library(ggplot2)

#' Load the [`gapminder`](https://github.com/jennybc/gapminder) data package.
#  install.packages("gapminder")
library(gapminder)
gapminder

ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) # nothing to plot yet!

ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
  geom_point()

p <-
  ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) # just initializes

#' scatterplot

  p + geom_point()

#' log transformation ... quick and dirty

  ggplot(gapminder, aes(x = log10(gdpPercap), y = lifeExp)) +
    geom_point()
  
#' a better way to log transform

  p + geom_point() + scale_x_log10()

#' let's make that stick

  p <- p + scale_x_log10()

#' common workflow: gradually build up the plot you want  
#' re-define the object 'p' as you develop "keeper" commands  

#' convey continent by color: MAP continent variable to aesthetic color

  p + geom_point(aes(color = continent))

## add summary(p)!

  ggplot(gapminder, aes(x = gdpPercap, y = lifeExp, color = continent)) +
    geom_point() + scale_x_log10() # in full detail, up to now

#' address overplotting: SET alpha transparency and size to a value

  p + geom_point(alpha = (1/3), size = 3)

#' add a fitted curve or line. "lm" fit s a linear model line
#' 
#'  

  p + geom_point() + geom_smooth()
  
  p + geom_point() + geom_smooth(lwd = 3, se = FALSE)
  
  p + geom_point() + geom_smooth(lwd = 3, se = FALSE, method = "lm")
  
#' revive our interest in continents!
  
  p + aes(color = continent) + geom_point() +
    geom_smooth(lwd = 3, se = FALSE)
  
# GGPlot Facetting is a very useful higher order visualization

#' facetting: another way to exploit a factor

  p + geom_point(alpha = (1 / 3), size = 3) +
    facet_wrap(~ continent)
  
  p + geom_point(alpha = (1 / 3), size = 3) +
    facet_wrap(~ continent) +
    geom_smooth(lwd = 2, se = FALSE)
  
#' Exercises:  
#' ========================================

#' * plot lifeExp against year  

  ggplot(gapminder, aes(x = year, y = lifeExp,
                        color = continent)) +
    geom_jitter(alpha = 1 / 3, size = 3)
  
#' * make mini-plots, split out by continent
#' HINT: use facet_wrap() 

  ggplot(gapminder, aes(x = year, y = lifeExp,
                        color = continent)) +
    facet_wrap(~ continent, scales = "free_x") +
    geom_jitter(alpha = 1 / 3, size = 3) +
    scale_color_manual(values = continent_colors)
  
  ggplot(
    subset(gapminder, continent != "Oceania"),
    aes(
      x = year,
      y = lifeExp,
      group = country,
      color = country
    )
  ) +
    geom_line(lwd = 1, show_guide = FALSE) + facet_wrap(~ continent) +
    scale_color_manual(values = country_colors) +
    #scale_color_brewer()+
    theme_bw() + theme(strip.text = element_text(size = rel(1.1)))
  

#' * add a fitted smooth and/or linear regression, w/ or w/o facetting  

  ggplot(gapminder, aes(x = year, y = lifeExp,
                        color = continent)) +
    facet_wrap(~ continent, scales = "free_x") +
    geom_jitter(alpha = 1 / 3, size = 3) +
    scale_color_manual(values = continent_colors) +
    geom_smooth(lwd = 2)
  
#' To make explicit what package a function comes from
#' Use explicity naming by dplyr::filter()

library(dplyr)

#' * use `dplyr::filter()` to plot lifeExp against
#' year for just one country or continent

  jc <- "Cambodia"

  gapminder %>%
    filter(country == jc) %>%
    ggplot(aes(x = year, y = lifeExp)) +
    labs(title = jc) +
    geom_line()
  
# [Khmer Rouge](https://en.wikipedia.org/wiki/Khmer_Rouge#Crimes_against_humanity)

  rwanda <- gapminder %>%
    filter(country == "Rwanda")
  
  p <- ggplot(rwanda, aes(x = year, y = lifeExp)) +
    labs(title = "Rwanda") +
    geom_line()
  
  print(p)
  
  ggsave("rwanda.pdf")
  
  ggsave("rwanda.pdf", plot = p)
  
# https://en.wikipedia.org/wiki/Rwandan_genocide 

#' * other ideas?  


#' plot lifeExp against year

  (y <- ggplot(gapminder, aes(x = year, y = lifeExp)) + geom_point())

#' make mini-plots, split out by continent

  y + facet_wrap(~ continent)

#' add a fitted smooth and/or linear regression, w/ or w/o facetting

  y + geom_smooth(se = FALSE, lwd = 2) +
    geom_smooth(
      se = FALSE,
      method = "lm",
      color = "orange",
      lwd = 2
    )
  
  
  y + geom_smooth(se = FALSE, lwd = 2) +
    facet_wrap( ~ continent)
  
#' last bit on scatterplots  
#' how can we "connect the dots" for one country?  
#' i.e. make a spaghetti plot?

  y + facet_wrap( ~ continent) + geom_line() # uh, no
  
  y + facet_wrap( ~ continent) + geom_line(aes(group = country)) # yes!
  
  y + facet_wrap( ~ continent) + geom_line(aes(group = country)) +
    geom_smooth(se = FALSE, lwd = 2)
  
#' note about subsetting data

#' sadly, ggplot() does not have a 'subset =' argument  
#' so do that 'on the fly' with subset(..., subset = ...)
  ggplot(subset(gapminder, country == "Zimbabwe"),
         aes(x = year, y = lifeExp)) + geom_line() + geom_point()
  
#' or could do with dplyr::filter

  ggplot(gapminder %>% filter(country == "Zimbabwe"),
         aes(x = year, y = lifeExp)) + geom_line() + geom_point()
  
#' let just look at four countries

  jCountries <- c("Canada", "Rwanda", "Cambodia", "Mexico")
  
  ggplot(subset(gapminder, country %in% jCountries),
         aes(x = year, y = lifeExp, color = country)) + geom_line() + geom_point()
  
#' when you really care, make your legend easy to navigate  
#' this means visual order = data order = factor level order

  ggplot(subset(gapminder, country %in% jCountries),
         aes(
           x = year,
           y = lifeExp,
           color = reorder(country, -1 * lifeExp, max)
         )) +
    geom_line() + geom_point()
  
#' another approach to overplotting
#' ggplot(gapminder, aes(x = gdpPercap, y = lifeExp)) +

  ggplot(gapminder, aes(x = gdpPercap, y = lifeExp)) +
    scale_x_log10() + geom_bin2d()
  
# Check whats loaded in you session

  sessionInfo()

#=================================================================
# Stripplots
#=================================================================
  
  #' ---
  #' author: "Jenny Bryan"
  #' output:
  #'   html_document:
  #'     keep_md: TRUE
  #' ---
  
  #+ setup, include = FALSE

  library(knitr)
  
  ?knitr
  
  opts_chunk$set(fig.path = 'figs/bryan/stripplot-', error = TRUE)

#' Note: this HTML is made by applying `knitr::spin()` to an R script. So the
#' narrative is very minimal.

  library(ggplot2)

#' pick a way to load the data
#gdURL <- "http://tiny.cc/gapminder"
#gapminder <- read.delim(file = gdURL) 
#gapminder <- read.delim("gapminderDataFiveYear.tsv")

  library(gapminder)

  str(gapminder)

#' stripplots: univariate scatterplots (but w/ ways to also convey 1+ factors)

  ggplot(gapminder, aes(x = continent, y = lifeExp)) + geom_point()

# Adding Jitter to a categorical variable plot can help visualization

#' we have an overplotting problem; need to spread things out

  ggplot(gapminder, aes(x = continent, y = lifeExp)) + geom_jitter()

#' we can have less jitter in x, no jitter in y, more alpha transparency

  ggplot(gapminder, aes(x = continent, y = lifeExp)) +
    geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1 /
                  4)
  
#' boxplots -- covered properly elsewhere

  ggplot(gapminder, aes(x = continent, y = lifeExp)) + geom_boxplot()

#' raw data AND boxplots

  ggplot(gapminder, aes(x = continent, y = lifeExp)) +
    geom_boxplot(outlier.colour = "hotpink") +
    geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1 /
                  4)
  
  #' raw data AND violinplots
  
  ggplot(gapminder, aes(x = continent, y = lifeExp)) +
    geom_violin(outlier.colour = "hotpink") +
    geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1 /
                  4)
  
#' superpose a statistical summary

  ggplot(gapminder, aes(x = continent, y = lifeExp)) +
    geom_jitter(position = position_jitter(width = 0.1), alpha = 1 / 4) +
    stat_summary(
      fun.y = median,
      colour = "red",
      geom = "point",
      size = 5
    )
  
#' let's reorder the continent factor based on lifeExp

  ggplot(gapminder, aes(reorder(x = continent, lifeExp), y = lifeExp)) +
    geom_jitter(position = position_jitter(width = 0.1), alpha = 1 / 4) +
    stat_summary(
      fun.y = median,
      colour = "red",
      geom = "point",
      size = 5
    )
  

  sessionInfo()

#==================================================================
#  Exploring distribution of a quantitative variable
#==================================================================
  
  #' ---
  #' author: "Jenny Bryan"
  #' output: github_document
  #' ---
  
  #+ setup, include = FALSE

  library(knitr)
  opts_chunk$set(fig.path = 'figs/bryan/uni-quant-', error = TRUE)
  
#' Note: this is rendered by applying `knitr::spin()` to an R script. So the
#' narrative is very minimal.

#' load the data and ggplot2 (part of the tidyverse)

  library(tidyverse)

  ?tidyverse


  library(gapminder)

  gapminder

#' distribution of a quant var: histogram

  ggplot(gapminder, aes(x = lifeExp)) +
    geom_histogram()

#' experiment with bin width; think in terms of the units of the x variable

  ggplot(gapminder, aes(x = lifeExp)) +
    geom_histogram(binwidth = 1)

#' show the different continents, but it's weird to stack up the
#' histograms, which is what default of `position = "stack"` delivers

  ggplot(gapminder, aes(x = lifeExp, fill = continent)) +
    geom_histogram()

#' `position = "identity"` is good to know about
#' it's still weird to layer them on top of each other like this

  ggplot(gapminder, aes(x = lifeExp, fill = continent)) +
    geom_histogram(position = "identity")

#' geom_freqpoly() is better in this case

  ggplot(gapminder, aes(x = lifeExp, color = continent)) +
    geom_freqpoly()

#' smooth histogram = densityplot

  ggplot(gapminder, aes(x = lifeExp)) + geom_density()

#' you should look at different levels of smoothing

  ggplot(gapminder, aes(x = lifeExp)) + geom_density(adjust = 1)

  ggplot(gapminder, aes(x = lifeExp)) + geom_density(adjust = 0.2)

#' densityplots work better in terms of one continent not obscuring another

  ggplot(gapminder, aes(x = lifeExp, color = continent)) + geom_density()

#' alpha transparency works here too

  ggplot(gapminder, aes(x = lifeExp, fill = continent)) +
    geom_density(alpha = 0.2)
  
#' with only two countries, maybe we should ignore Oceania?

  ggplot(subset(gapminder, continent != "Oceania"),
       aes(x = lifeExp, fill = continent)) + geom_density(alpha = 0.2)

#' facets work here too

  ggplot(gapminder, aes(x = lifeExp)) + geom_density() + facet_wrap( ~ continent)
  
  
  ggplot(subset(gapminder, continent != "Oceania"),
         aes(x = lifeExp, fill = continent)) + geom_histogram() +
    facet_grid(continent ~ .)
  
#' boxplot for one quantitative variable against a discrete variable  
#' first attempt does not work since year is not formally a factor

  ggplot(gapminder, aes(x = year, y = lifeExp)) + geom_boxplot()

#' by explicitly specifying year as the grouping variable, we get what we want

  ggplot(gapminder, aes(x = year, y = lifeExp)) + geom_boxplot(aes(group = year))

# Violin Plots, a new visualization
# http://ggplot2.tidyverse.org/reference/geom_violin.html

#' try geom_violin() instead and just generally goofing off now

  ggplot(gapminder, aes(x = year, y = lifeExp)) +
    geom_violin(aes(group = year)) +
    geom_jitter(alpha = 1 / 4) +
    geom_smooth(se = FALSE)
  
#================================================================
#  Drawing Bars
#================================================================
  
  #' ---
  #' author: "Jenny Bryan"
  #' output: github_document
  #' ---
  
  #+ setup, include = FALSE
  
  library(knitr)

  opts_chunk$set(fig.path = 'figs/bryan/uni-factor-', error = TRUE)

#' Note: this is rendered by applying `knitr::spin()` to an R script. So the
#' narrative is very minimal.



#' load the data and ggplot2 (part of the tidyverse)

  library(tidyverse)

  library(gapminder)

  gapminder

#' bar charts  
#' consider: no. of observations for each continent

  table(gapminder$continent)

#' this works because default stat for geom_bar() is "bin"

  ggplot(gapminder, aes(x = continent)) + geom_bar()

#' let's reorder the continents based on frequency

  p <- ggplot(gapminder, aes(x = reorder(continent, continent, length)))

  p + geom_bar()

#' would you rather the bars run horizontally?

  p + geom_bar() + coord_flip()

#' how about a better data:ink ratio?

  p + geom_bar(width = 0.05) + coord_flip()

#' consider a scenario where you DON'T want the default "bin" stat, i.e. the bar
#' length or height already exists as a variable

  (continent_freq <- gapminder %>% count(continent))

#' this simple call no longer works, because we have pre-tabulated

  ggplot(continent_freq, aes(x = continent)) + geom_bar()

#' THIS works when bar length or height already exists

  ggplot(continent_freq, aes(x = continent, y = n)) + geom_bar(stat = "identity")
  

  sessionInfo()

#================================================================
#  Change overall look and feel via themes
#================================================================
  
  #' ---
  #' author: "Jenny Bryan"
  #' output:
  #'   html_document:
  #'     keep_md: TRUE
  #' ---
  
  #+ setup, include = FALSE

  library(knitr)

  opts_chunk$set(fig.path = 'figs/bryan/themes-', error = TRUE)

#' Note: this HTML is made by applying `knitr::spin()` to an R script. So the
#' narrative is very minimal.


  library(ggplot2)

  # install.packages("ggthemes")

  library(ggthemes)

    ?ggthemes
  
#' pick a way to load the data
#gdURL <- "http://tiny.cc/gapminder"
#gapminder <- read.delim(file = gdURL) 
#gapminder <- read.delim("gapminderDataFiveYear.tsv")

  library(gapminder)

  str(gapminder)

#' revisit a plot from earlier

  p <- ggplot(gapminder, aes(x = gdpPercap, y = lifeExp))

  p <- p + scale_x_log10()

  p <- p + aes(color = continent) + geom_point() + geom_smooth(lwd = 3, se = FALSE)

  p

#' give it a title

  p + ggtitle("Life expectancy over time by continent")

#' change overall look and feel with a premade theme

  p + theme_grey() # the default

#' suppress the usual grey background

  p + theme_bw()

#' exploring some themes from the ggthemes package  
#' https://github.com/jrnold/ggthemes

  p + theme_calc() + ggtitle("ggthemes::theme_calc()")
  
  p + theme_economist() + ggtitle("ggthemes::theme_economist()")
  
  p + theme_economist_white() + ggtitle("ggthemes::theme_economist_white()")
  
  p + theme_few() + ggtitle("ggthemes::theme_few()")
  
  p + theme_gdocs() + ggtitle("ggthemes::theme_gdocs()")
  
  p + theme_tufte() + ggtitle("ggthemes::theme_tufte()")
  
  p + theme_wsj() + ggtitle("ggthemes::theme_wsj()")
  

  sessionInfo()

#==============================================================
#  Take control of a qualitative color scheme
#==============================================================

  #' ---
  #' author: "Jenny Bryan"
  #' output:
  #'   html_document:
  #'     keep_md: TRUE
  #' ---
  
  #+ setup, include = FALSE
  library(knitr)

  opts_chunk$set(fig.path = 'figs/bryan/colors-', error = TRUE)

#' Note: this HTML is made by applying `knitr::spin()` to an R script. So the
#' narrative is very minimal.


  library(ggplot2)

  # install.packages("RColorBrewer")

  library(RColorBrewer)

  ?RColorBrewer
  
#' pick a way to load the data
#gdURL <- "http://tiny.cc/gapminder"
#gapminder <- read.delim(file = gdURL) 
#gapminder <- read.delim("gapminderDataFiveYear.tsv")

  library(gapminder)

  str(gapminder)

#' let just look at four countries
  
  jCountries <- c("Canada", "Rwanda", "Cambodia", "Mexico")
  
  x <- droplevels(subset(gapminder, country %in% jCountries))
  
  ggplot(x, aes(x = year, y = lifeExp, color = country)) +
    geom_line() + geom_point()
  
#' reorder the country factor to reflect lifeExp in 2007

  x <- transform(x, country = reorder(country, -1 * lifeExp, max))

  ggplot(x, aes(x = year, y = lifeExp, color = country)) +
    geom_line() + geom_point()

#' look at the RColorBrewer color palettes

  display.brewer.all()

#' focus on the qualitative palettes

  display.brewer.all(type = "qual")

#' pick some colors

  jColors = brewer.pal(n = 8, "Dark2")[seq_len(nlevels(x$country))]

  names(jColors) <- levels(x$country)

#' remake the plot with our new colors

  ggplot(x, aes(x = year, y = lifeExp, color = country)) +
    geom_line() + geom_point() +
    scale_color_manual(values = jColors)
  
#' pick some super ugly colors for shock value

  kColors = c("darkorange2", "deeppink3", "lawngreen", "peachpuff4")
  
  names(kColors) <- levels(x$country)
  
#' remake the plot with our ugly colors

  ggplot(x, aes(x = year, y = lifeExp, color = country)) +
    geom_line() + geom_point() +
    scale_color_manual(values = kColors)
  
  sessionInfo()
  
#==============================================================
#  Bubble and line plots, lots of customization
#==============================================================
  
  #' ---
  #' author: "Jenny Bryan"
  #' output:
  #'   html_document:
  #'     keep_md: TRUE
  #' ---
  
  #+ setup, include = FALSE
  library(knitr)

  opts_chunk$set(fig.path = 'figs/bryan/shock-awe-', error = TRUE)

#' Note: this HTML is made by applying `knitr::spin()` to an R script. So the
#' narrative is very minimal.

  library(ggplot2)

#' pick a way to load the data
#gdURL <- "http://tiny.cc/gapminder"
#gapminder <- read.delim(file = gdURL) 
#gapminder <- read.delim("gapminderDataFiveYear.tsv")

  library(gapminder)
  str(gapminder)

#' drop Oceania

  gapminder <- droplevels(subset(gapminder, continent != "Oceania"))

#' Note that the gapminder package ships with color schemes for countries and continents.

  head(country_colors)
  
  jYear <- 2007 # this can obviously be changed
  jPch <- 21
  jDarkGray <- 'grey20'
  jXlim <- c(150, 115000)
  jYlim <- c(16, 100)
  
  ggplot(subset(gapminder, year == jYear),
         aes(x = gdpPercap, y = lifeExp)) +
    scale_x_log10(limits = jXlim) + ylim(jYlim) +
    geom_point(
      aes(size = sqrt(pop / pi)),
      pch = jPch,
      color = jDarkGray,
      show_guide = FALSE
    ) +
    scale_size_continuous(range = c(1, 40)) +
    facet_wrap( ~ continent) + coord_fixed(ratio = 1 / 43) +
    aes(fill = country) + scale_fill_manual(values = country_colors) +
    theme_bw() + theme(strip.text = element_text(size = rel(1.1)))
  
  ggplot(gapminder, aes(x = year, y = lifeExp, group = country)) +
    geom_line(lwd = 1, show_guide = FALSE) + facet_wrap( ~ continent) +
    aes(color = country) + scale_color_manual(values = country_colors) +
    theme_bw() + theme(strip.text = element_text(size = rel(1.1)))
  

