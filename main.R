library(tercen)
library(dplyr)
library(reshape2)

(ctx = tercenCtx())  %>% 
  select(.ci, .ri, .y) %>% 
  reshape2::acast(.ci ~ .ri, value.var='.y', fun.aggregate=mean) %>%
  prcomp(scale=FALSE, center=FALSE, na.action=na.omit) %>%
  predict() %>%
  as_tibble() %>%
  mutate(.ci = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()

