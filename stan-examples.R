#### LOAD PACKAGES ####
library(tidyverse) # For data manipulation
library(rstan)     # For interfacing with Stan compiler
library(shinystan) # For web-based Stan model assessment tools
library(bayesplot) # For R-based Stan model object plotting

#### READ DATA ####
setwd("~/Box Sync/Work/Teaching and Mentoring/Yale/Statistical modeling/stan-workshop-may2020")
load("data.RData")

#### GLOBAL STAN SPECIFICATIONS ####
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

#### SIMPLE LINEAR REGRESSION ####
# Data list
m1.dat <- list(
  N = nrow(data),
  y = data$resp,
  x = data$moist.trt
)

# Translate Stan code to C++ and compile
mod1 <- stan_model("m1.stan")
# Fit the model
fit1 <- sampling(mod1, data = m1.dat, iter=2000, warmup=1000, chains=3)

# Alternatively, do both of the above steps in one
m1 <- stan(file = "m1.stan", data = m1.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)
print(m1)

# Plot the main coefficient
beta_draws <- as.matrix(m1, pars = "beta")
colnames(beta_draws) <- c("Soil moisture")
bayesplot::mcmc_intervals(beta_draws)

# Alternatively, we can do this in shiny
launch_shinystan(m1)
# Go to Estimate >> Parameters Plot

#### LINEAR REGRESSION WITH PRIORS ####
m2.dat <- list(
  N = nrow(data),
  y = data$resp,
  x = data$moist.trt,
  mu = 0.001,
  tau = 0.01
)

m2 <- stan(file = "m2.stan", data = m2.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)
print(m2)
print(m2, pars=c('alpha','beta','sigma'))

# Posterior predictive check 
# Assess how well predicted data overlap with observed data
y_rep_m2 <- as.matrix(m2, pars = "y_rep")
samp_m2 <- sample(nrow(y_rep_m2), 100)
ppc_dens_overlay(m2.dat$y, y_rep_m2[samp_m2, ])

#### GENERALIZED MODEL ####
m3 <- stan(file = "m3.stan", data = m1.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)
print(m3, pars = c('alpha','beta','sigma'))

# Posterior predictive check 
y_rep_m3 <- as.matrix(m3, pars = "y_rep")
samp_m3 <- sample(nrow(y_rep_m3), 100)
ppc_dens_overlay(m1.dat$y, y_rep_m3[samp_m3, ])

#### MULTIPLE REGRESSION ####
m4.dat <- list(
  N = nrow(data),
  y = data$resp,
  moistTreat = data$moist.trt,
  moistPlot = data$moisturePercent
)

m4 <- stan(file = "m4.stan", data = m4.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)
print(m4, pars = c('alpha','betaTreat','betaPlot','sigma'))

# Alternatively, you can pass a matrix
# I'm also going to standardize the data
data$moistTreatStd <- (data$moist.trt - mean(data$moist.trt))/2*sd(data$moist.trt)
data$moistPercStd <- (data$moisturePercent - mean(data$moisturePercent))/2*sd(data$moisturePercent)

m5.dat <- list(
  N = nrow(data),
  y = data$resp,
  X = data[,c('moistTreatStd','moistPercStd')],
  K = ncol(data[,c('moistTreatStd','moistPercStd')])
)

m5 <- stan(file = "m5.stan", data = m5.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)
print(m5, pars = c('alpha','beta','sigma'))

# Posterior predictive check of measurement error
y_rep_m5 <- as.matrix(m5, pars = "y_rep")
samp_m5 <- sample(nrow(y_rep_m5), 100)
ppc_dens_overlay(m5.dat$y, y_rep_m5[samp_m5, ])

# Plot the model object
beta_draws <- as.matrix(m5, pars = "beta")
colnames(beta_draws) <- c("Experimental moisture", "Original moisture")
mcmc_intervals(beta_draws)

# Try this with shiny stan
y = data$resp
launch_shinystan(m5)
# Go to Estimate >> Parameters Plot
# For PP Check, Go to Diagnose >> PPCheck

#### HIERARCHICAL MODELS ####
m6.dat <- list(
  N = nrow(data),
  y = data$resp,
  X = data[,c('moistTreatStd','moistPercStd')],
  site = as.numeric(as.factor(data$site)),
  K = data[,c('moistTreatStd','moistPercStd')] %>% ncol(),
  J = data$site %>% as.factor() %>% as.numeric() %>% unique() %>% length()
)

m6 <- stan(file = "m6.stan", data = m6.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)
print(m6, pars=c('alpha','beta','sigma'))

# Compare sites (for zero moisture)
draws <- as.matrix(m6, pars = c("alpha"))
colnames(draws) <- c("Site 1","Site 2")
mcmc_intervals(draws)

#### MEASUREMENT ERROR (IN X) ####
m7.dat <- list(
  N = nrow(data),
  y = data$resp,
  moistTreat = data$moist.trt,
  moistPlotObs = data$moisturePercent,
  site = data$site %>% as.factor %>% as.numeric(),
  J = data$site %>% as.factor() %>% as.numeric() %>% unique() %>% length(),
  tau = 2
)

m7 <- stan(file = "m7.stan", data = m7.dat,
           iter = 2000,
           warmup = 1000,
           chains = 3)

# Posterior predictive check of measurement error
x_rep_m7 <- as.matrix(m7, pars = "moistPlot")
samp_m7 <- sample(nrow(x_rep_m7), 100)
ppc_dens_overlay(m7.dat$moistPlotObs, x_rep_m7[samp_m7, ])

print(m7, pars=c('alpha','betaTreat','betaPlot','sigma'))

#### MEASUREMENT ERROR (IN Y) ####
m8.dat <- list(
  N = nrow(data),
  y_obs = data$resp,
  y_err = rep(5, nrow(data)),
  moistTreat = data$moist.trt,
  moistPlotObs = data$moisturePercent,
  site = data$site %>% as.factor %>% as.numeric(),
  J = data$site %>% as.factor() %>% as.numeric() %>% unique() %>% length(),
  tau = 2
)

m8 <- stan(file = "m8.stan", data = m8.dat,
           iter = 5000,
           warmup = 2000,
           control=list(adapt_delta=0.99,
                        max_treedepth=15),
           chains = 3)

# Posterior predictive check of measurement error in y
y_rep_m8 <- as.matrix(m8, pars = "y_rep")
samp_m8 <- sample(nrow(y_rep_m8), 100)
ppc_dens_overlay(m8.dat$y_obs, y_rep_m8[samp_m8, ])

print(m8, pars=c('alpha','betaTreat','betaPlot','sigma'))

