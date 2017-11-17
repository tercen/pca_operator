library(tercen)
library(dplyr)
library(reshape2)

(ctx = tercenCtx())  %>% 
  select(.ci, .ri, .y) %>% 
  reshape2::acast(.ci ~ .ri, value.var='.y', fun.aggregate=mean) %>%
  prcomp(scale=as.logical(ctx$op.value('scale')), 
         center=as.logical(ctx$op.value('center')), 
         na.action=get(ctx$op.value('na.action'))) %>%
  predict() %>%
  as_tibble() %>%
  mutate(.ci = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()

