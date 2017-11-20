library(tercen)
library(dplyr)
library(reshape2)
 
pca.data = (ctx = tercenCtx())  %>% 
  select(.ci, .ri, .y) %>% 
  reshape2::acast(.ci ~ .ri, value.var='.y', fun.aggregate=mean) %>%
  prcomp(scale=as.logical(ctx$op.value('scale')), 
         center=as.logical(ctx$op.value('center')), 
         tol=as.double(ctx$op.value('tol')), 
         na.action=get(ctx$op.value('na.action'))) %>%
  predict() 

maxComp = as.integer(ctx$op.value('maxComp'))

if (maxComp > 0){
  maxComp = min(maxComp, ncol(pca.data))
  pca.data = pca.data[,1:maxComp]
}
 
pca.data %>%
  as_tibble() %>%
  mutate(.ci = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()

