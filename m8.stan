data {
  // Data dimensions
  int<lower=0> N;         // number of cases
  int<lower=0> J;         // number of intercepts
  
  // Response variable
  vector[N] y_obs;        // Observed value of response variable
  vector[N] y_err;        // Case-specific error in response variable
  
  // Predictor variables
  vector[N] moistTreat;   // Moisture treatment
  vector[N] moistPlotObs; // Measured value of soil moisture
  real<lower=0> tau;      // Known measurement noise
  
  // Random effect
  int site[N];            // Grouping factor
}

parameters {
  // True distribution of y
  vector[N] y;
  real mu_y;    // prior location
  real sigma_y; // prior scale

  // True distribution of plot moisture
  vector[N] moistPlot;  // unknown true value
  real mu_moistPlot;    // prior location
  real sigma_moistPlot; // prior scale

  // Model parameters
  vector[J] alpha;      // vector of intercepts
  real betaTreat;       // treament slope
  real betaPlot;        // plot slope
  real<lower=0> sigma;  // outcome noise
}

model {
  // Measurement error in y
  y ~ normal(mu_y, sigma_y);
  y_obs ~ normal( y , y_err );

  // Measurement error in plot moisture
  moistPlot ~ normal(mu_moistPlot, sigma_moistPlot);
  moistPlotObs ~ normal(moistPlot, tau);
  
  // Model priors 
  alpha ~ normal(0, 10);
  betaTreat ~ normal(0, 10);
  betaPlot ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
  
  // Likelihood
  for (n in 1:N)
    y_obs[n] ~ normal(alpha[site[n]] + moistTreat[n] * betaTreat + moistPlot[n] * betaPlot, sigma);
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N)
    y_rep[n] = normal_rng(alpha[site[n]] + moistTreat[n] * betaTreat + moistPlot[n] * betaPlot, sigma);
}
