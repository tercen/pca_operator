library(tercen)
library(dplyr)
library(reshape2)


df= (ctx = tercenCtx())  %>% select(.ci, .ri, .y) 

bTranspose = as.character(ctx$op.value("input.convention")) == "observations.in.columns"

if (bTranspose){
  df = df %>% mutate(ci = .ri, ri = .ci)
} else {
  df = df %>% mutate(ri = .ri, ci = .ci)
}
  
aPca= df %>% 
  reshape2::acast(ri~ci, value.var='.y', fun.aggregate=mean) %>% prcomp()
  prcomp(scale=as.logical(ctx$op.value('scale')),
         center=as.logical(ctx$op.value('center')),
         tol=as.double(ctx$op.value('tol')),
         na.action=get(ctx$op.value('na.action')))

maxComp = as.integer(ctx$op.value('maxComp'))
maxComp = ifelse(maxComp > 0, min(maxComp, ncol(aPca$x)), ncol(aPca$x))

scores = aPca$x[,1:maxComp] %>% as_tibble()
colnames(scores) = paste(colnames(scores),"scores", sep = ".") 
scores = scores %>% mutate(ri = 0:(nrow(.)-1), ci = 0)

loadings = aPca$rotation[,1:maxComp] %>% as_tibble()
colnames(loadings) = paste(colnames(loadings), "loadings", sep = ".")
loadings = loadings %>% mutate(ci = 0:(nrow(.)-1), ri = 0)

v.explained = (aPca$sdev[1:maxComp])^2 
p.var.explained = matrix(nrow = 1, data = v.explained / sum(v.explained)) %>% as_tibble()
colnames(p.var.explained) = paste("PC", 1:nrow(loadings),".p.var.explained", sep = "")
p.var.explained = p.var.explained %>% mutate(ri = 0, ci = 0)

pca.data = full_join(scores, loadings, by = c("ri", "ci")) %>% 
  full_join(p.var.explained, by = c("ri", "ci"))

if (bTranspose){
  pca.data = pca.data %>% mutate(.ri = ci, .ci = ri)
} else {
  pca.data = pca.data %>% mutate(.ri = ri, .ci = ci)
}

pca.data %>%
  select(-ri, -ci) %>%
  ctx$addNamespace() %>%
  ctx$save()