library(tercen)
library(dplyr)

(ctx = tercenCtx())  %>% 
  select(.cindex, .rindex, .values) %>% 
  reshape2::acast(.cindex ~ .rindex, value.var='.values', fun.aggregate=mean) %>%
  prcomp(scale=FALSE, center=FALSE, na.action=na.omit) %>%
  predict() %>%
  as_tibble() %>%
  mutate(.cindex = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()

