# Bayesian Hierarchical Model for Target Persistence in Surface Waters #

require(rstan)

# The training data consists of 400 datasets with optimized k1 and k2 parameter values, experimental
# conditions (temperature, sunlight, predation, target type, water type), and T90 values 
# The testing data consists of experimental conditions for 110 datasets, and the observed T90 value for each dataset.

training_data <- read.csv("Data for Surface Water Persistence Hierarchical Model.csv")
testing_data <- read.csv("Testing Data for Surface Water Persistence Hierarchical Model.csv")

# Set up the necessary data for fitting the linear model
X1 <- cbind.data.frame(training_data[ ,"Temp"], training_data[  ,"Predation"], training_data[  ,"Water"])  # Matrix with the training data conditions impacting k1
colnames(X1) <- c("Temp","Predation", "Water"); rownames(X1) <- NULL

X2 <-  cbind.data.frame(training_data[ ,"Water"])  # Matrix with the training data conditions impacting k2
colnames(X2) <- c("Water"); rownames(X1) <- NULL

X3 <- cbind.data.frame(testing_data[ ,"Temp"], testing_data[  ,"Predation"], testing_data[  ,"Water"])  # Matrix with the testing data conditions impacting k1
colnames(X3) <- c("Temp", "Predation", "Water"); rownames(X3) <- NULL

X4 <-  cbind.data.frame(testing_data[ ,"Water"])   # Matrix with the testing data conditions impacting k2
colnames(X4) <- c("Water"); rownames(X4) <- NULL


J=5                              # number of total target types
id <- training_data[ ,"Target"]  # target type in training data
id2 <- testing_data[ ,"Target"]  # target type in testing data
N=nrow(training_data[ ,])        # number of observations/experiments in training data
N2=nrow(testing_data[ ,])        # number of observations/experiments in testing data
K <- 3                           # number of regression coefficients for k1
L <- 1                           # number of regression coefficients for k2

w <- training_data[ , "k1"]      # k1 parameters for each dataset in the training data (k1 is continuous)
y <- log(training_data[ , "k2"]) # k2 parameters for each dataset in the training data (k2 is positive only)


data_list <-list(N=N,N2=N2, J=J,K=K,L=L,id=id,id2=id2,  # list with all the data needed for the Stan model
                 X1=X1,X2=X2,X3=X3,X4=X4, w=w, y=y)

hier_persistence <- stan(file="multilevel_dep_normal.stan",data=data_list, chains=2, iter = 3000, warmup = 1000,  # Fitting the model 
                    control=list(adapt_delta=0.95))

results_dataframe <- summary(hier_persistence)$summary[1:20,]  # Distributions of parameter values in the hierarchical model
rowid <- c("k1_intercept_pop", "k1_intercept_FIB", "k1_intercept_Bact","k1_intercept_Pha", "k1_intercept_Vir", "k1_intercept_Prot", "k1_intercept_sigma",
           "k2_intercept_pop", "k2_intercept_FIB", "k2_intercept_Bact","k2_intercept_Pha", "k2_intercept_Vir", "k2_intercept_Prot","k2_intercept_sigma",
           "temp_coefficient_k1", "pred_coefficient_k1", "water_coefficient_k1", "water_coefficient_k2",
           "k1_scale", "k2_sigma")
rownames(results_dataframe) <- rowid
colnames(results_dataframe) <- colnames(summary(hier_persistence)$summary)
round(results_dataframe,2)
