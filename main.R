library(tercen)
library(tercenApi)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)

source('operator_functions.R')

ctx = tercenCtx()

scale = ctx$op.value("scale", type=as.logical, default = FALSE)  
center = ctx$op.value("center", type=as.logical, default = TRUE)  
tol = ctx$op.value("tol", type=as.double, default = 0)
maxComp = ctx$op.value("maxComp", type=as.integer, default=4)  


props = list( scale=scale, center=center, tol=tol, maxComp=maxComp )

plist <- props
pnames <- unlist(unname(names(props)))


params <- c(ctx, setNames(plist,pnames))
res <- do.call('pca_func', params )

save_relation(res, ctx)
