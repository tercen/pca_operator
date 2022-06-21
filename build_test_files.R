library(tercen)
library(tercenApi)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(tim)

# Function definitions
source('operator_functions.R')


# http://127.0.0.1:5402/test-team/w/b417efa5e0df231fc5968497a302cce5/ds/b16ac50e-96bf-42b5-b095-c33d82f05def
# Test cases
wkfId <- "b417efa5e0df231fc5968497a302cce5"
options("tercen.workflowId"= wkfId)

stepIdList <- c("b16ac50e-96bf-42b5-b095-c33d82f05def")


# Steps with properties
propDictList <- list()
# propDictList <- list("MaxComps"=list(stepId="5490bf87-8f01-4cfa-a392-036e9eb51f92",
#                                      maxComp=8),
#                      "Default"=list(stepId="5490bf87-8f01-4cfa-a392-036e9eb51f92"))


for( i in seq(1, length(stepIdList))){
  options("tercen.stepId"=stepIdList[i])  
  ctx = tercenCtx()
  
  # Get step name
  step_name <- get_step_name(ctx, wkfId, stepIdList[i])
  print(step_name)
  
  
  has_property_list <- lapply(  propDictList, function(x){
    x$stepId == stepIdList[i]
  })
  
  if( any(unname(unlist(has_property_list)))){
    
    prop_list_idx <- which(unname(unlist(has_property_list)))
    for(j in prop_list_idx){
      
      props <- propDictList[j]
      test_suff <- unlist(unname(names(props)))[1]
      props <- props[[test_suff]]
      props$stepId <- NULL
      
      plist <- props
      pnames <- unlist(unname(names(props)))
      
      
      step_name_ex <- paste0(step_name, "_", test_suff)
      
      
      params <- c(ctx, setNames(plist,pnames))
      res <- do.call('pca_func', params )
      
      tim::build_test_data( res, ctx, paste0(step_name_ex, "_absTol"),
                            version = '1.3.1',
                            absTol = 0.001,
                            props=setNames(plist,pnames))
      
      
    }
  }else{
    res <- pca_func( ctx )
    
    tim::build_test_data( res, ctx, paste0(step_name, "_absTol"),
                          version = '1.3.1',
                          absTol = 0.001)
  }
}


