// Stan file for a multilevel regression with Juneja and Marks 2 persistence 
// model parameters (k1 and k2) as the dependent variables, and the temperature
// of the water, water type, and predation status as the independent variables.
// 
// The hyperdistributions for k1 and k2 are the double exponential and normal 
// distributions, respectively. Weakly informative priors were selected based
// on prior work with the Juneja and Marks 2 model in wastewater matrices and
// groundwater. 

data {
  int<lower=1> N; //the number of experiments
  int<lower=1> N2; //number of testing datasets
  int<lower=1> J; //the number of target groups
  int<lower=1> K; //number of columns in the model matrix for k1 (coefficients for temp, predation, water type)
  int<lower=1> L; //number of columns in the model matrix for k2 (coefficient for water type)
  int<lower=1,upper=J> id[N];   //vector of group indeces (1=FIB, 2=Bacteria, 3=Bacteriophage, 4=Virus, 5=Protozoa)
  int<lower=1,upper=J> id2[N2]; //vector of group indeces (1=FIB, 2=Bacteria, 3=Bacteriophage, 4=Virus, 5=Protozoa)
  matrix[N,K] X1; //the model matrix for training conditions impacting k1
  matrix[N,L] X2; //the model matrix for training conditions impacting k2
  vector[N] w;    //response variable k1
  vector[N] y;    //response variable k2
   
  matrix[N2,K] X3; //matrix of testing data conditions 
  matrix[N2,L] X4; //matrix of testing data conditions 
 
}
parameters {
  
  real alpha1_tot;
  vector[J] alpha1;
  real<lower=0> sigma_alpha1;
  
  
  real alpha2_tot;
  vector[J] alpha2;
  real<lower=0> sigma_alpha2;
  
  
  vector[K] beta1;       //population-level regression coefficients for k1
  vector[L] beta2;       //population-level regression coefficients for log(k2)

  real<lower=0> sigma1;  //standard deviation of the individual observations of k1
  real<lower=0> sigma2;  //standard deviation of the individual observations of k2
 
}


model {
  vector[N] mu1; //linear predictor
  vector[N] mu2; //linear predictor
 
  alpha1_tot ~ normal(0,8);  //weakly informative priors on the regression coefficients
  alpha2_tot ~ normal(0.5,2); //weakly informative priors on the regression coefficients
  
  sigma_alpha1 ~ gamma(5,1);
  sigma_alpha2 ~ gamma(5,5);
  
  sigma1 ~ gamma(1,0.5); //weakly informative priors
  sigma2 ~ gamma(5,2); //weakly informative priors
  
 
  for (k in 1:K) {
    beta1[k] ~ normal(0,2); //weak prior for beta1
  }
  
  for (l in 1:L) {
    beta2[l] ~ normal(0,2); //weak prior for beta2
  }
  
  for (m in 1:J) {
    alpha1[m] ~ normal(alpha1_tot,sigma_alpha1); //weak prior for alpha1
    alpha2[m] ~ normal(alpha2_tot,sigma_alpha2); //weak prior for alpha2
  }
  
  for(n in 1:N){
     mu1[n] = alpha1[id[n]] + X1[n]*beta1;  //compute k1 using relevant group-level regression coefficients 
     mu2[n] = alpha2[id[n]] + X2[n]*beta2;; //compute k2 using relevant group-level regression coefficients 
     
     
}
  //likelihood
  w ~ double_exponential(mu1,sigma1);
  y ~ normal(mu2,sigma2);
  
}

generated quantities {
  real k1_pred[N];
  real k2_pred[N];
  vector[N] log_lik_1;
  vector[N] log_lik_2;
  vector[N] log_lik;
  vector[N2] new_pred_k1;
  vector[N2] new_pred_k2;
  
  for (n in 1:N) {
    k1_pred[n] = double_exponential_rng(alpha1[id[n]]+X1[n]*beta1, sigma1);
    k2_pred[n] = normal_rng(alpha2[id[n]]+X2[n]*beta2, sigma2);
    
    log_lik_1[n] = double_exponential_lpdf(w[n] |  alpha1[id[n]] + X1[n]*beta1 , sigma1);
    log_lik_2[n] = normal_lpdf(y[n] |  alpha2[id[n]] + X2[n]*beta2, sigma2);
    log_lik[n] = log_lik_1[n] + log_lik_2[n];
    
  }
   for  (s in 1:N2){
    new_pred_k1[s] = double_exponential_rng(alpha1[id2[s]] + X3[s]*beta1, sigma1);
    new_pred_k2[s] = normal_rng(alpha2[id2[s]] + X4[s]*beta2, sigma2);
    
  }

 
}
