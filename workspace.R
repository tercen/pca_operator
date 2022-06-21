library(tercen)
library(tercenApi)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)

library(tim)
library(jsonlite)

source('operator_functions.R')

# http://127.0.0.1:5402/test-team/w/b417efa5e0df231fc5968497a302cce5/ds/b16ac50e-96bf-42b5-b095-c33d82f05def
options("tercen.workflowId"="b417efa5e0df231fc5968497a302cce5")
options("tercen.stepId"="b16ac50e-96bf-42b5-b095-c33d82f05def")

ctx = tercenCtx()

props = list( scale=FALSE, center=TRUE, tol=0, maxComp=4 )

plist <- props
pnames <- unlist(unname(names(props)))


params <- c(ctx, setNames(plist,pnames))
res <- do.call('pca_func', params )

test_name <- 'UC001_c03_absTol'
tim::run_local_test( res, ctx, test_name, 
                test_folder = NULL, 
                absTol=0.1, docIdMapping=c())

save_relation(res, ctx)



