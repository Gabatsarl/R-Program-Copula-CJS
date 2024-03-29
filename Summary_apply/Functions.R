#-----------------------------------------------------------------------------------------#
#
# This program implements the functions (7) used in the paper application section 5
#
#
#-----------------------------------------------------------------------------------------#


# Function 1: Density fonction for beta(alpha,beta, lambda)

dbeta3<-function(x,alpha,beta,lambda){
 (lambda/(1-(1-lambda)*x)^2)*dbeta(lambda*x/(1-(1-lambda)*x),alpha,beta)
}

# Function 2: cdf of beta3 
pbeta3<-function(x,alpha,beta,lambda){
  x2<-pbeta(lambda*x/(1-x*(1-lambda)),alpha,beta);
  x2
}


# Function 3: qbeta_inv : Inverse of pbeta3 (F^-1)
pbeta3_inv<-function(x, alpha,beta, lambda){
  resul<-qbeta(x,alpha,beta)/(lambda+(1-lambda)*qbeta(x,alpha,beta)) ;
  resul
}

## Function 4: Likelihood function for parameters estimations of the 2-exchangeable copula model 
#                with c2 is Khoudraji copula 

Likelihood_2exchangeable<-function(para,data){
  # Input : @data : three-column data frame : Column 1: School (1:m), m is number of cluster
  #                                          Column 2: variable x
  #                                          Column 3: variable y
  #                                 - F :  beta distribution of x with parameters alpha1,beta1
  #                                 - G :  beta distribution of y with parameters alpha2,beta2 et lambda
  #                                 - c1 : normal copula with parameter rho1
  #                                 - c2 : Khoudraji copula with parameters delta2, kappa1, kappa2
  #                                 - c3 : normal copula with parameter rho3
  # Output : likelihood of equation l(para)=l1+l2+l3
  
  
  alpha1<-para[1] ; beta1<-para[2]  
  
  alpha2<-para[3] ; beta2<-para[4]; lambda<-para[5]
  
  eta1<-para[6] ; rho1<-exp(eta1)/(1+exp(eta1))
  eta2<-para[7]; rho2<-exp(eta2)/(1+exp(eta2))
  eta4<-para[8]; kappa1<-exp(eta4)/(1+exp(eta4))
  eta5<-para[9]; kappa2<-exp(eta5)/(1+exp(eta5))
  eta3<-para[10] ; rho3<-exp(eta3)/(1+exp(eta3))
  m<-max(data[,1])  ## Number of school
  
  # transform using F and G
  u0<-pbeta(data[,2],alpha1,beta1)
  v0<-pbeta3(data[,3],alpha2,beta2,lambda)

  
  l1<--sum(log(dbeta(data[,2],alpha1,beta1))) ## f0 
  
  l2<--sum(log(dbeta3(data[,3],alpha2,beta2,lambda))) # g0
  
  ## copula c1: normal of parameters @rho1
  l01<-0
  for(i in 1:m){
    ##-------Part III-1 of likelihood ------#
    ind<-which(data[,1]==i)
    #lnC1<--dCopula(u0[ind],normalCopula(rho1, dim=length(ind)),log=TRUE)
    l01<-l01-dCopula(u0[ind],normalCopula(rho1, dim=length(ind)),log=TRUE)
  }
  
  ## copula c2: khoudraji of parameters @(kappa1,kappa2,rho2)
    ##-------Part III-2 of likelihood ------#
  koudraji<-khoudrajiCopula(copula1 =indepCopula(), copula2 =normalCopula(rho2),shape = c(kappa1,kappa2))
  l02<- -sum(dCopula(matrix(cbind(1-u0,1-v0),ncol=2),koudraji,log=TRUE))
  
  # wij 
  w0<-1+(kappa1-1)*(1-u0)^(-kappa1)*(1-v0)^(1-kappa2)*pCopula(matrix(cbind((1-u0)^kappa1,(1-v0)^kappa2),ncol=2),normalCopula(rho2,dim=2))-
                  kappa1*(1-v0)^(1-kappa2)*pnorm((qnorm((1-v0)^kappa2)-rho2*qnorm((1-u0)^kappa1))/sqrt(1-rho2^2))
  
  ## Copula c3: normal of parameters @rho1
  l03<-0
  for(i in 1:m){
    ##-------Part III-3 of likelihood ------#
    ind1<-which(data[,1]==i)
    l03<-l03-dCopula(w0[ind1],normalCopula(rho3,dim=length(ind1)),log=TRUE)
  }
  return(l1+l2+l01+l02+l03)
}



# Function 5: prediction function for 2-exchangeable copula: This function predicts the value of y
#             knowing xn with equation (17) by conditional expectation

Prediction_2_exchangeable=function(i,K,data,alpha1,beta1,alpha2,beta2,lambda,delta2,kappa1,kappa2,delta3){
  # Input : @data : three-column data frame: Column 1 : School (1:m)
  #                                           Column 2 : variable x
  #                                           Column 3 : variable y
  #                                 - Estimated of alpha1,beta1, alpha2, beta2, lambda, delta2
  #                                   kappa1, kappa2,delta3
  #                                 - @K the number of quadrature points
  #                                 - @i the school to which the individual belongs
  # Output : The predictions in school i knowing several values of xn(u)  
  
  
  quadra<-gauss.quad(K,kind="hermite") # 10 number of quadrature points
  u<-seq(.01,.99,by=.01)

  # index of individuals in the school we're interested in
  ind<-which(data[,1]==i)
  
  # Transformation of u0 and v0
  u0<-pbeta(data[,2][ind],alpha1,beta1)
  v0<-pbeta(lambda*data[,3][ind]/(1-(1-lambda)*data[,3][ind]),alpha2,beta2)
  
  
  # calculate for w0
  koudraji<-khoudrajiCopula(copula1 =indepCopula(),copula2 =normalCopula(delta2) ,shape = c(kappa1,kappa2))
  z<-pCopula(matrix(cbind((1-u0)^kappa1,(1-v0)^kappa2),ncol=2),koudraji)
  w0<-1-(1-kappa1)*(1-u0)^(-kappa1)*(1-v0)^(1-kappa2)*z-kappa1*(1-v0)^(1-kappa2)*BiCopHfunc1(u1=(1-u0)^kappa1,u2=(1-v0)^kappa2, family=1, par=delta2)
  
  # Calculate mu0 and sig0
 
  n0=length(ind)
  mu0=mean(qnorm(w0))*n0*delta3/(1+(n0-1)*delta3)
  sig0=sqrt((1-delta3)*(1+n0*(delta3))/(1+(n0-1)*delta3))
  
  
  # calculate a prediction
  xpred<-ypred<-numeric(0)
  predv<-rep(0,K)
  for (ii in 1:length(u)){
    valu<-qbeta(u[ii],alpha1, beta1)
    xpred<-c(xpred,valu)
    # conditional distribution of v knowing u C(v|u)
    F_vu<-function(v){
      a<-1+(kappa1-1)*(1-u[ii])^(-kappa1)*(1-v)^(1-kappa2)*pCopula(c((1-u[ii])^kappa1,(1-v)^kappa2),normalCopula(delta2,dim=2))-
        kappa1*(1-v)^(1-kappa2)*pnorm((qnorm((1-v)^kappa2)-delta2*qnorm((1-u[ii])^kappa1))/sqrt(1-delta2^2))
      return(a)
      }
    # Inverse of C(v|u)
    
    Inv_F_c<-inverse(F_vu,lower=0,upper=1) #--Inverse de F_v
    
    for (i in (1:K)){
      predv[i]<-pbeta3_inv(Inv_F_c(pnorm(mu0+sqrt(2)*sig0*quadra$nodes[i])),alpha2,beta2,lambda)
     } 
    
    ypred<-c(ypred,sum(quadra$weights*predv)/sqrt(pi))
   }
  
  return(list(xpred=xpred,ypred=ypred))
}



# Function 6 : Estimation of model residuals: This function predicts y 
# knowing x with ypred for data elements then calculates @resid=(y-ypred)


residual_exchangeable_model<-function(K=10,data,alpha1,beta1,alpha2,beta2,lambda,delta2,kappa1,kappa2,delta3){
  # Input : @data : three-column dataframe : Column 1 : School (1:m)
  #                                              Column 2 : variable x
  #                                              Column 3 : variable y
  #                                 - Estimated of alpha1,beta1, alpha2, beta2, lambda, delta2
  #                                   kappa1, kappa2,delta3
  #                                 - @K the number of quadrature points
  #
  # Output : Model residuals (y-ypred)  

  quadra<-gauss.quad(K,kind="hermite") # 10 number of quadrature points
  
  #  u0 and v0 (tranformation of x et y)
  u0<-pbeta(data[,2],alpha1,beta1)
  v0<-pbeta(lambda*data[,3]/(1-(1-lambda)*data[,3]),alpha2,beta2)
  
  
  # calculate for w0
  
  
  koudraji<-khoudrajiCopula(copula1 =indepCopula(),
                            copula2 =normalCopula(delta2) ,shape = c(kappa1,kappa2))
  
  z<-pCopula(matrix(cbind((1-u0)^kappa1,(1-v0)^kappa2),ncol=2),normalCopula(delta2,dim=2))
  w0<-1-(1-kappa1)*(1-u0)^(-kappa1)*(1-v0)^(1-kappa2)*z-kappa1*(1-v0)^(1-kappa2)*BiCopHfunc1(u1=(1-u0)^kappa1,u2=(1-v0)^kappa2, family=1, par=delta2)
  
  # claculate mu0 and sig0
  sni<-dim(data)[1]
  m<-max(data[,1])
  data$mu0<-rep(0,sni)
  data$sig0<-rep(0,sni)
  for(i in 1:m){
    indi<-which(data[,1]==i)
    n0=length(indi)
    data[indi,"mu0"]=mean(qnorm(w0[indi]))*n0*delta3/(1+(n0-1)*delta3)
    data[indi,"sig0"]=sqrt((1-delta3)*(1+n0*(delta3))/(1+(n0-1)*delta3))
   }
  
  
  
  # prediction
  predv<-rep(0,10)
  yinit<-data[,3] ; 
  ypred<-rep(0,sni)
  for (ii in (1:sni)){
     uu<-pbeta(data[ii,2],alpha1,beta1)
     F_vu<-function(v){
        a<-1+(kappa1-1)*(1-uu)^(-kappa1)*(1-v)^(1-kappa2)*pCopula(c((1-uu)^kappa1,(1-v)^kappa2),normalCopula(delta2,dim=2))-
            kappa1*(1-v)^(1-kappa2)*pnorm((qnorm((1-v)^kappa2)-delta2*qnorm((1-uu)^kappa1))/sqrt(1-delta2^2))
        return(a)
      }
     Inv_F_c<-inverse(F_vu,lower=0,upper=1) #--Inverse de F_v
     mu0<-data$mu0[ii]; sig0<-data$sig0[ii]
     for (i in (1:10)){
        predv[i]<-pbeta3_inv(Inv_F_c(pnorm(mu0+sqrt(2)*sig0*quadra$nodes[i])),alpha2,beta2,lambda)
       }
      ypred[ii]<-sum(quadra$weights*predv)/sqrt(pi)
     }
            
    return((yinit-ypred))              
}




# Function 7 : Conditionnal density function: calculates the conditional density of equation (16)


## function for g_p(G^-1(v))=g(y)*c2(u,v)*((1/sqrt(2pi)*sig0)*exp(-1/(sig0^2)*(t-mu0)^2)/phi(t))
#                            p1*  p2 *      p3     
#
#
#------------------------ Equation (13)--------------------------------------------------------------#


Conditionnal_density<-function(i,x0,K=10,data,vde=seq(.0005,.9995,by=0.001),alpha1,beta1,alpha2,beta2,lambda,delta2,kappa1,kappa2,delta3){
  
  # Input : @data : three-column dataframe : Column 1 : School (1:m)                                      #
  #                                          Column 2 : variable x
  #                                          Column 3 : variable y
  #                                 - Estimated of alpha1,beta1, alpha2, beta2, lambda, delta2
  #                                   kappa1, kappa2,delta3
  #                                 - @K the number of quadrature points
  #                                 - @i the school to which the individual belongs
  # - x0 the known value of the explanatory variable
  # Output :  conditional density g_p(y) 
  
  yde<-pbeta3_inv(vde,alpha2,beta2,lambda)
  
  # Identify the cluster
  ind<-which(data[,1]==i)
  
  # transforme u0 and v0
  u0<-pbeta(data[,2][ind],alpha1,beta1)
  v0<-pbeta(lambda*data[,3][ind]/(1-(1-lambda)*data[,3][ind]),alpha2,beta2)
  
  
  # calculate for w0
  koudraji<-khoudrajiCopula(copula1 =indepCopula(), copula2 =normalCopula(delta2) ,shape = c(kappa1,kappa2))
  z<-pCopula(matrix(cbind((1-u0)^kappa1,(1-v0)^kappa2),ncol=2),koudraji)
  w0<-1-(1-kappa1)*(1-u0)^(-kappa1)*(1-v0)^(1-kappa2)*z-kappa1*(1-v0)^(1-kappa2)*BiCopHfunc1(u1=(1-u0)^kappa1, u2=(1-v0)^kappa2, family=1, par=delta2)
  
  # Calculate mu0 and sig0 of School i
  n0=length(ind)
  mu0=mean(qnorm(w0))*n0*delta3/(1+(n0-1)*delta3)
  sig0=sqrt((1-delta3)*(1+n0*(delta3))/(1+(n0-1)*delta3))
  
  
  # component I : G(y) or y =G^-1(v)
  ude<-pbeta(x0,alpha1, beta1)   ## x0 fixé, calcul F(x0)
  part1<-dbeta3(yde,alpha2,beta2,lambda)
  
  # component II conditionnal for survival copula c_2(1-u,1-v)  
  koudraji<-khoudrajiCopula(copula1 =indepCopula(), copula2 =normalCopula(delta2),shape = c(kappa1,kappa2))
  part2<-dCopula(matrix(cbind(1-ude,1-vde),ncol=2),koudraji)
  
  # component III
  c3<-qnorm(1+(kappa1-1)*(1-ude)^(-kappa1)*(1-vde)^(1-kappa2)*pCopula(cbind((1-ude)^kappa1,(1-vde)^kappa2),normalCopula(delta2,dim=2))-
                 kappa1*(1-vde)^(1-kappa2)*pnorm((qnorm((1-vde)^kappa2)-delta2*qnorm((1-ude)^kappa1))/sqrt(1-delta2^2)))
  
  part3<-dnorm(c3,mean=mu0,sd=sig0)/dnorm(c3)
  
  # Final result
  densi<-part1*part2*part3  ## final density 
  
  return(list(yde=yde,densi=densi))
  
}


# End
