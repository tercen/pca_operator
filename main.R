library(tercen)
library(dplyr)
library(reshape2)

df = (ctx = tercenCtx())  %>% select(.ci, .ri, .y) 

input.convention <- "observations.in.columns"
if(!is.null(ctx$op.value("input.convention"))) input.convention <- as.character(ctx$op.value("input.convention"))

bTranspose = input.convention == "observations.in.columns"

if (bTranspose){
  df = df %>% mutate(ci = .ri, ri = .ci)
} else {
  df = df %>% mutate(ri = .ri, ci = .ci)
}

scale <- FALSE
if(!is.null(ctx$op.value("scale"))) scale <- as.logical(ctx$op.value("scale"))
center <- TRUE
if(!is.null(ctx$op.value("center"))) center <- as.logical(ctx$op.value("center"))
tol <- 0.1
if(!is.null(ctx$op.value("tol"))) tol <- as.double(ctx$op.value("tol"))
na.action <- "na.omit"
if(!is.null(ctx$op.value("na.action"))) na.action <- get(ctx$op.value("na.action"))

aPca = df %>% 
  reshape2::acast(ri ~ ci, value.var = '.y', fun.aggregate = mean) %>% 
  prcomp(scale = scale,
         center = center,
         tol = tol,
         na.action = na.action)

eigenvalues <- aPca$sdev^2
var_explained <- (eigenvalues / sum(eigenvalues))
eigen_df <- data.frame(pc = paste0("pc_", seq_along(eigenvalues)), eigenvalues, var_explained)
eigen_df$ci = 0; eigen_df$ri = 0

maxComp = 5
if(!is.null(ctx$op.value('maxComp'))) maxComp = as.integer(ctx$op.value('maxComp'))
maxComp = ifelse(maxComp > 0, min(maxComp, ncol(aPca$x)), ncol(aPca$x))

scores = aPca$x[,1:maxComp] %>% as_tibble()
colnames(scores) = paste(colnames(scores),"scores", sep = ".") 
scores = scores %>% mutate(ri = 0:(nrow(.)-1), ci = 0)

loadings = aPca$rotation[,1:maxComp] %>% as_tibble()
colnames(loadings) = paste(colnames(loadings), "loadings", sep = ".")
loadings = loadings %>% mutate(ci = 0:(nrow(.)-1), ri = 0)

pca.data = full_join(scores, loadings, by = c("ri", "ci")) 
pca.data = full_join(pca.data, eigen_df, by = c("ri", "ci")) 

if (bTranspose){
  pca.data = pca.data %>% mutate(.ri = as.integer(ci), .ci = as.integer(ri))
} else {
  pca.data = pca.data %>% mutate(.ri = as.integer(ri), .ci = as.integer(ci))
}

pca.data <- pca.data %>%
  select(-ri, -ci) %>%
  ctx$addNamespace() %>% 
  ctx$save()
