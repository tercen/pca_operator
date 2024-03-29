pca_func <- function( ctx, scale = FALSE, center = TRUE, tol=0, maxComp=5){
  data.matrix = t(ctx %>% as.matrix())
  
  aPca = data.matrix %>% prcomp(scale = scale, center = center, tol = tol)
  
  maxComp = ifelse(maxComp > 0, min(maxComp, nrow(aPca$rotation)), nrow(aPca$rotation))
  
  npc = length(aPca$sdev)
  
  # pad left pc names with 0 to ensure alphabetic order
  pcRelation = tibble(PC = sprintf(paste0("PC%0", nchar(as.character(npc)), "d"), 1:npc)) %>%
    ctx$addNamespace() %>%
    as_relation()
  
  eigenRelation = tibble(pc.eigen.values = aPca$sdev^2) %>% 
    mutate(var_explained = .$pc.eigen.values / sum(.$pc.eigen.values))%>% 
    ctx$addNamespace() %>%
    as_relation()
  
  loadingRelation = aPca$rotation[,1:maxComp] %>%
    as_tibble() %>%
    setNames(0:(ncol(.)-1)) %>%
    mutate(.var.rids = 0:(nrow(.) - 1)) %>%
    pivot_longer(-.var.rids,
                 names_to = ".pc.rids",
                 values_to = "pc.loading",
                 names_transform=list(.pc.rids=as.integer)) %>%
    ctx$addNamespace() %>%
    as_relation() %>%
    left_join_relation(ctx$rrelation, ".var.rids", ctx$rrelation$rids)
  
  scoresRelation = aPca$x[,1:maxComp] %>%
    as_tibble() %>%
    setNames(0:(ncol(.)-1)) %>%
    mutate(.i=0:(nrow(.)-1)) %>%
    pivot_longer(-.i,
                 names_to = ".pc.rids",
                 values_to = "pc.value",
                 names_transform=list(.pc.rids=as.integer)) %>%
    ctx$addNamespace() %>%
    as_relation() %>%
    left_join_relation(ctx$crelation, ".i", ctx$crelation$rids)
  
  # link all 4 relation into one and save 
  rels <- pcRelation %>%
    left_join_relation(scoresRelation, pcRelation$rids, ".pc.rids")  %>%
    left_join_relation(eigenRelation, pcRelation$rids, eigenRelation$rids) %>%
    left_join_relation(loadingRelation, pcRelation$rids, ".pc.rids") %>%
    as_join_operator(ctx$cnames, ctx$cnames)
  
  return(rels)
  
}