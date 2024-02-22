The file Functions.R has to be sourced.  It contains R-code implementing the functions needed for the
analysis presented in Section 6 of the paper. The file Application.R presents the R instructions to carry our the 
analysis of Goldstein (2011) data set.

Here is a list of the steps in the analysis:

1-Create Goldstein (2011) data using the data set jsp728 of the package lmeresampler.  This is stored in the data frame data.sch
2-Carry out the maximum likelihood estimation of the 10 patameters of the model.  This is given in res1
3-Calculate the regresssion curves for school 1 and 3 and create Figure 6
4-Calculate the copula model residuals and compare them with residuals from linear mixed models
5-Evaluate preditive densities in School 1 and 3 and create Figure 7.
