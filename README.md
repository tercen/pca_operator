# Principal Components Analysis



```
https://github.com/tercen/pca-operator.git
```

```R

packrat::init(options = list(
  use.cache = TRUE,
  external.packages = 'devtools',
  load.external.packages.on.startup = FALSE))
  
devtools::install_github("tercen/TSON", ref = "1.4-rtson", subdir="rtson", upgrade_dependencies = FALSE)
devtools::install_github("tercen/teRcen", ref = "0.4.1", upgrade_dependencies = FALSE)

remove.packages("tercen", lib = "./packrat/lib/x86_64-pc-linux-gnu/3.3.2")
remove.packages("rtson", lib = "./packrat/lib/x86_64-pc-linux-gnu/3.3.2")
```

```R

packrat::status()
packrat::snapshot()

packrat::bundle(include.src=FALSE, overwrite = TRUE, include.bundles=FALSE)

```

