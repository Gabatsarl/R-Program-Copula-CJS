
##------------------------------------------------
#
#  
#  This file contains calls to the R packages needed to
#  analyse the data in Section 6.
#  It also provides the R-code needed:
#  1-to fit the proposed model  by maximum likelihood and to get Table 6
#  2- to redo the residual analysis on pages 38-39
#  3- to draw  Figures 5 &6, 

#   The R-code in this file uses the R-functions in Functions.R
#  that needs to be sourced before running the code in this file.
#------------------------------------------------



## source R code containing the functions to be used


source("C:\\Users\\...\\Functions.R")

# install and load the followong packages

library(copula)
library(VineCopula)
library(fitdistrplus) 
library(GoFKernel)
library(statmod)
library(ggplot2)
library(lmeresampler)



# load the data from lmeresampler

data("jsp728")  # School 10 and 43 are skipped, so renumerate as follows
u<-unique(jsp728$school) ; school<-rep(0,dim(jsp728)[1])
for (i in 1:length(u)){ ind<-which(jsp728$school==u[i]); school[ind]<-i }
jsp728$school<-school

data.sch=jsp728[,c("school","mathAge8","mathAge11")]
data.sch$math1t=(data.sch$mathAge8+.5)/41+rnorm(length(data.sch$mathAge8),sd=0.0001)
data.sch$math3t=(data.sch$mathAge11+.5)/41+rnorm(length(data.sch$mathAge11),sd=0.0001)
data.sch=data.frame(data.sch[,c("school","math1t","math3t")])


# Estimation of global model parameters (Table 6) from "Likelihood_2exchangeable". 
# with nlimb then use optim to obtain standard errors
# initialization of parameters based on parameter estimation, ignoring school effect

parai<-c(4.38,2.52,2.614,2.31,.29,log(.06/.94),log(.78/.22),log(.82/.18),log(.98/.02),log(.16/.84) )

xx<-nlminb(parai,Likelihood_2exchangeable, data=data.sch)
Likelihood_2exchangeable(parai,data.sch)
xx1<-optim(xx$par,fn=Likelihood_2exchangeable,data=data.sch,hessian = TRUE)
# may take some time
# standard error for estimate parameters
sqrt(diag(solve(xx1$hessian)))



## parameters
para<-xx$par
alpha1=para[1]; beta1=para[2] ;
alpha2=para[3]; beta2=para[4];lambda=para[5] 
delta1=exp(para[6])/(1+exp(para[6])) ;delta2=exp(para[7])/(1+exp(para[7]));
kappa1=exp(para[8])/(1+exp(para[8]))
kappa2=exp(para[9])/(1+exp(para[9])); delta3=exp(para[10])/(1+exp(para[10]))
c(alpha1,beta1,alpha2,beta2,lambda,delta1,delta2,kappa1,kappa2,delta3)

## Prediction : Figure 5 is obtained with the "Prediction_2_exchangeable" function
# applied to 2 schools (i=1 and i=30)

# school 1
Pred_School1<-Prediction_2_exchangeable(i=1,K=10,data=data.sch,alpha1=alpha1,beta1=beta1,
                          alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                          kappa1=kappa1,kappa2=kappa2,delta3=delta3)


xpred1<-Pred_School1$xpred; ypred1<-Pred_School1$ypred
plot(xpred1,ypred1,type="l")

# school 30
Pred_School30<-Prediction_2_exchangeable(i=30,K=10,data=data.sch,alpha1=alpha1,beta1=beta1,
                                        alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                                        kappa1=kappa1,kappa2=kappa2,delta3=delta3)

xpred30<-Pred_School30$xpred; ypred30<-Pred_School30$ypred
plot(xpred30,ypred30,type="l")

# Construct fig5

fig5<-ggplot() +
  geom_line(data = data.frame(x = xpred1, y = ypred1), aes(x = x, y = y), size= 1.5, linetype = "solid", color = "red") +
  geom_line(data = data.frame(x = xpred30, y = ypred30), aes(x = x, y = y), size = 1.5, linetype = "solid", color = "blue") +
  geom_point(data = subset(data.sch, school == 1), aes(x = math1t, y = math3t),size = 2.5, shape = 20, color = "red") +
  geom_point(data = subset(data.sch, school == 30), aes(x = math1t, y = math3t), size = 2.5, shape = 20, color = "blue") +
  xlim(0.2, 1) +
  ylim(0.2, 1) +
  labs(x = "X", y = "Y pred") +
  scale_color_manual(values = c("1" = "red", "30" = "blue"))


fig5
# estimation of residuals of 2-exchangeable model with "prediction_error" function output list
# of two elements "yde" and "densi"


Resid_exch<-residual_exchangeable_model(K=10,data=data.sch,alpha1=alpha1,beta1=beta1,
                                        alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                                        kappa1=kappa1,kappa2=kappa2,delta3=delta3)

# residual 
#Proposed model
resid_CM<-Resid_exch
mean(resid_CM^2)  #  .0107
IQR(resid_CM) #0  .1073281
#Linear mixed models
library(nlme)
xx<-lme(math3t ~ math1t , random=~1|factor(school), data=data.sch)
summary(xx)
mean(residuals(xx)^2) #.0112
IQR(residuals(xx)) #.1186
xx1<-lme(math3t ~ math1t , random=~1+math1t|factor(school), data=data.sch,  control=list(returnObject=TRUE))
summary(xx1)
mean(residuals(xx1)^2)# .01011
IQR(residuals(xx1))  # .1094
mean(abs(residuals(xx1))>abs(resid_CM)) #.527
## Figure 6 densities are calculated with "Conditionnal_density" output 

# School 1 
result1_1<-Conditionnal_density(i=1,x0=0.4,K=10,data=data.sch,vde=seq(.0005,.9995,by=0.001),
                                alpha1=alpha1,beta1=beta1,alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                                kappa1=kappa1,kappa2=kappa2,delta3=delta3)
result1_2<-Conditionnal_density(i=1,x0=0.9,K=10,vde=seq(.0005,.9995,by=0.001),data=data.sch,
                                alpha1=alpha1,beta1=beta1,alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                                kappa1=kappa1,kappa2=kappa2,delta3=delta3)

# School 30
result2_1<-Conditionnal_density(i=30,x0=0.4,K=10,vde=seq(.0005,.9995,by=0.001),data=data.sch,
                                alpha1=alpha1,beta1=beta1,alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                                kappa1=kappa1,kappa2=kappa2,delta3=delta3)

result2_2<-Conditionnal_density(i=30,x0=0.9,K=10,vde=seq(.0005,.9995,by=0.001),data=data.sch,
                                alpha1=alpha1,beta1=beta1,alpha2=alpha2,beta2=beta2,lambda=lambda,delta2=delta2,
                                kappa1=kappa1,kappa2=kappa2,delta3=delta3)


## construct of figure 6

yde<-result1_1$yde;  ## y
School1_x40<-result1_1$densi ; School1_x90<-result1_2$densi; # g_p(y) for School 1
School30_x40<-result2_1$densi; School30_x90<-result2_2$densi # g_p(y) for School 30

plot(yde,School1_x40, xlab="y", ylab=expression(g[p](y)),type="l",lwd=2, ylim=c(0,16))
lines(yde,School1_x90, type="l",lty=2, lwd=2,ylim=c(0,16))
lines(yde,School30_x40, type="l",col="red", lwd=2,ylim=c(0,16))
lines(yde,School30_x90, type="l",col="red", lty=2, lwd=2)


