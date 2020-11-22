library(tercen)
library(dplyr)
library(reshape2)
#http://localhost:5402/admin/w/74962fe230eecdb297022e226100c0f8/ds/efc1bcbe-b973-4c91-8f7e-11094b6076c6

#http://localhost:5402/admin/w/74962fe230eecdb297022e226100c0f8/ds/efc1bcbe-b973-4c91-8f7e-11094b6076c6
#https://stage.tercen.com/rdewijn/w/a1f59de071388157e39701100b0da1b1/ds/efeab2ad-b10c-407e-847d-4c2fd4674fbb

# options("tercen.serviceUri"="https://stage.tercen.com/api/v1")
# options("tercen.username"="rdewijn")
# options("tercen.password"="cloudy.69")

# options("tercen.serviceUri"="http://127.0.0.1:5402/api/v1/")
# options("tercen.username"="admin")
# options("tercen.password"="admin")

options("tercen.workflowId"= "74962fe230eecdb297022e226100c0f8")
#options("tercen.stepId"= "21-3")
options("tercen.stepId"= "efc1bcbe-b973-4c91-8f7e-11094b6076c6")

df= (ctx = tercenCtx())  %>% select(.ci, .ri, .y) 

#bTranspose = get(ctx$op.value("input.convention")) == "observations.in.columns"
bTranspose = FALSE
if (bTranspose){
  df = df %>% mutate(ci = .ri, ri = .ci)
} else {
  df = df %>% mutate(ri = .ri, ci = .ci)
}
  
aPca= df %>% 
  reshape2::acast(ri~ci, value.var='.y', fun.aggregate=mean) %>% prcomp()
  # prcomp(scale=as.logical(ctx$op.value('scale')), 
  #        center=as.logical(ctx$op.value('center')), 
  #        tol=as.double(ctx$op.value('tol')), 
  #        na.action=get(ctx$op.value('na.action')))

#maxComp = as.integer(ctx$op.value('maxComp'))
maxComp = 5
maxComp = ifelse(maxComp > 0, min(maxComp, ncol(aPca$x)), ncol(aPca$x))

scores = aPca$x[,1:maxComp] %>% as_tibble()
colnames(scores) = paste(colnames(scores),"scores", sep = ".") 
scores = scores %>% mutate(ri = 0:(nrow(.)-1), ci = 1)

loadings = aPca$rotation[,1:maxComp] %>% as_tibble()
colnames(loadings) = paste(colnames(loadings), "loadings", sep = ".")
loadings = loadings %>% mutate(ci = 0:(nrow(.)-1), ri = 1)

pca.data = full_join(scores, loadings, by = c("ri", "ci"))

if (bTranspose){
  pca.data = pca.data %>% mutate(.ri = ci, .ci = ri)
} else {
  pca.data = pca.data %>% mutate(.ri = ri, .ci = ci)
}

pca.data %>%
  select(-ri, -ci) %>%
  ctx$addNamespace() %>%
  ctx$save()
