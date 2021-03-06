
lmfit <- lm(mpg ~ wt, mtcars)
summary(lmfit)

library(ggplot2)
data(mtcars)
ggplot(mtcars, aes(mpg, wt)) + geom_point()

nlsfit <- nls(mpg ~ k / wt + b, mtcars, start=list(k=1, b=0))
summary(nlsfit)
ggplot(mtcars, aes(wt, mpg)) + geom_point() + geom_line(aes(y=predict(nlsfit)))

bootstrap <- function(df, m) {
  n <- nrow(df)

  attr(df, "indices") <- replicate(m, sample(n, replace = TRUE) - 1,
                                   simplify = FALSE)
  attr(df, "drop") <- TRUE
  attr(df, "group_sizes") <- rep(n, m)
  attr(df, "biggest_group_size") <- n
  attr(df, "labels") <- data.frame(replicate = 1:m)
  attr(df, "vars") <- list(quote(replicate))
  class(df) <- c("grouped_df", "tbl_df", "tbl", "data.frame")

  df
}

library(dplyr)
library(broom)
set.seed(2014)
bootnls <- mtcars %>% bootstrap(100) %>%
  do(tidy(nls(mpg ~ k / wt + b, ., start=list(k=1, b=0))))

alpha = .05
bootnls %>% group_by(term) %>% summarize(low=quantile(estimate, alpha / 2),
                                         high=quantile(estimate, 1 - alpha / 2))

