# pca operator

#### Description
`pca` operator performs principle component analysis.

##### Usage
Input projection|.
---|---
`row`   | represents the variables (e.g. genes, channels, markers)
`col`   | represents the observations (e.g. cells, samples, individuals) 
`y-axis`| measurement value


Input parameters|.
---|---
`scale`   | logical, indicating whether the variables should be scaled to have unit variance before the analysis takes place
`center`   | logical, indicating whether the variables should be shifted to be zero centered before the analysis takes place
`na.action`| A function which indicates what should happen when the data contain NAs
`tol`| numeric, indicating the magnitude below which components should be omitted. Components are omitted if their standard deviations are less than or equal to tol times the standard deviation of the first component
`maxComp`| numeric, maximum number of components to return, default 5


Output relations|.
---|---
`pca1, pca2, pca3, pca4, pca5`| first five components containing the new projected values


##### Details
The operator performs principal component analysis. It reduces the amount of variables (i.e. indicated by rows) to a lower number (default 5).


#### Reference

##### See Also


#### Examples
