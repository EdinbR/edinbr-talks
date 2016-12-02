################################################################
### 
### Hadley Wickham: Managing many models with R
###
###  https://www.youtube.com/watch?v=rz3_FDVt9eg
###
###  compiled by Fernando DePaolis-Middlebury Institute, USA
################################################################

library(gapminder)
library(dplyr)
library(purrr)
library(tidyr)
library(broom)
library(ggplot2)

gapminder

gapminder <- gapminder %>% mutate(year1950 = year - 1950)

# Nested data ---------------------------

by_country <- gapminder %>%
        group_by(continent, country) %>%
        nest()

by_country
str(by_country)
by_country$data[[1]]

# Fit models ------------------------------

country_model <- function(df) {
        lm(lifeExp ~ year1950, data = df)
}

models <- by_country %>%
        mutate(
                model = data %>% map(country_model)
        )
models
models %>% filter(continent == "Africa")

# Broom ---------------------------------

models <- models %>%
        mutate(
                glance  = model %>% map(broom::glance),
                rsq     = glance %>% map_dbl("r.squared"),
                tidy    = model %>% map (broom::tidy),
                augment = model %>% map (broom::augment)
        )
models

models %>% arrange(desc(rsq))
models %>% filter(continent == "Africa")

models %>%
        ggplot(aes(rsq, reorder(country, rsq))) +
        geom_point(aes(colour = continent)) +
        ylab("Countries-Descending Order rsq") + 
        theme(axis.text.y = element_text(hjust = 1, size = 3, color = "darkgray"))

#source("gapminder-shiny.R")   ### Search for this source code

# Unnest --------------------------------

unnest(models, data) # back to where we started
unnest(models, glance, .drop = TRUE) %>% View()
unnest(models, tidy)

models%>%
        unnest(tidy) %>%
        select(continent, country, term, estimate, rsq) %>%
        spread(term, estimate) %>%
        ggplot(aes(`(Intercept)`, year1950)) +
                geom_point(aes(colour = continent, size = rsq)) +
                geom_smooth(se = FALSE) + 
                xlab("Life Expectancy (1950)") +
                ylab("Yearly improvement") + 
                scale_size_area()

unnest(models, augment)

models %>%
        unnest(augment) %>%
        ggplot(aes(year1950, .resid)) +
                geom_line(aes(group = country), alpha = 1 / 3) +
                geom_smooth(se = FALSE) +
                geom_hline(yintercept = 0, colour = "white") +
                facet_wrap(~continent)





