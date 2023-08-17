# General-Persistence-Model-for-Surface-Waters
A Bayesian multilevel linear regression for estimating persistence model parameters for general target groups (FIB, bacteria, bacteriophages, viruses, protozoa) based on water quality conditions

The general persistence model for surface waters uses Bayesian hierarchical modeling methods, a two-parameter persistence model form, and a database of 400 indicator and pathogen persistence
experiments to provide general information about the persistence behaviors of fecal indicator bacteria, bacteriophages, bacteria, viruses, and protozoa in known surface water conditions (temperature,
water type, predation status). The database of the experiments and the identification of the optimal two-parameter persistence models have been described previously (Dean and Mitchell, 2022a; Dean 
and Mitchell, 2022b). This repository contains the training data, testing data, a Stan model, and the script for fitting the Stan model.

Prerequisites: 
Rstan is required for fitting this model. 

Use: 
To fit the general persistence model, open the Hierarchical_Model_Fitting_Script and run the script. Within the script, the multilevel linear regression (multilevel_dep_normal) is fit with 2 chains, 
3000 iterations per chain, and a 1000 iteration burn-in. The script produces the results_dataframe with the parameter estimates for the multilevel linear regression.
