data {
  int<lower=0> N;         // number of cases
  int<lower=0> J;         // number of intercepts
  vector[N] y;            // CO2 flux (variate)
  vector[N] moistTreat;   // Moisture treatment
  vector[N] moistPlotObs; // Measured value of soil moisture
  real<lower=0> tau;      // Known measurement noise
  int site[N];            // Grouping factor
}

parameters {
  // Model parameters
  vector[J] alpha;      // vector of intercepts
  real betaTreat;       // treament slope
  real betaPlot;        // plot slope
  real<lower=0> sigma;  // outcome noise
  
  // True distribution of plot moisture
  vector[N] moistPlot;  // unknown true value
  real mu_moistPlot;    // prior location
  real sigma_moistPlot; // prior scale
}

model {
  // Model priors 
  alpha ~ normal(0, 10);
  betaTreat ~ normal(0, 10);
  betaPlot ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
  
  // Measurement error in plot moisture
  moistPlot ~ normal(mu_moistPlot, sigma_moistPlot);
  moistPlotObs ~ normal(moistPlot, tau);
  
  // Likelihood
  for (n in 1:N)
    y[n] ~ normal(alpha[site[n]] + moistTreat[n] * betaTreat + moistPlot[n] * betaPlot, sigma);
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N)
    y_rep[n] = normal_rng(alpha[site[n]] + moistTreat[n] * betaTreat + moistPlot[n] * betaPlot, sigma);
}
