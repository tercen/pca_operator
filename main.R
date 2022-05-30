library(tercen)
library(dplyr)
library(reshape2)

ctx = tercenCtx()
df = ctx$as.matrix()

input.convention <- ctx$op.value("input.convention", as.character, "observations.in.columns")
if(input.convention == "observations.in.columns") df <- t(df)

scale <- ctx$op.value("scale", as.logical, FALSE)
center <- ctx$op.value("center", as.logical, TRUE)
tol <- ctx$op.value("tol", as.double, 0.1)
na.action <- ctx$op.value("na.action", as.character, "na.omit")
maxComp <- ctx$op.value("maxComp", as.double, 5)

aPca = df %>% 
  prcomp(scale = scale,
         center = center,
         tol = tol,
         na.action = na.action,
         rank. = maxComp)

eigenvalues <- aPca$sdev ^ 2
var_explained <- (eigenvalues / sum(eigenvalues))
eigen_df <- data.frame(pc = paste0("pc_", seq_along(eigenvalues)), eigenvalues, var_explained)

scores = aPca$x %>% as_tibble()
colnames(scores) = paste(colnames(scores), "scores", sep = ".") 
scores = scores %>% mutate(.ri = 0:(nrow(.) - 1)) %>%
  ctx$addNamespace()

loadings = aPca$rotation %>% as_tibble()
colnames(loadings) = paste(colnames(loadings), "loadings", sep = ".")
loadings = loadings %>% mutate(.ci = 0:(nrow(.) - 1)) %>%
  ctx$addNamespace()

df_out <- list(scores, loadings)

ctx$save(df_out)
