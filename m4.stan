data {
  int<lower=0> N;         // number of cases
  vector[N] y;            // CO2 flux (variate)
  vector[N] moistTreat;   // Soil moisture treatment    
  vector[N] moistPlot;    // initial gravimetric (quadrat moisture)
}

parameters {
  real alpha; // intercept
  real betaTreat;  // slope
  real betaPlot;
  real<lower=0> sigma;  // outcome noise
}

model {
  // Priors 
  alpha ~ normal(0, 10);
  betaTreat ~ normal(0, 10);
  betaPlot ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
  
  // Likelihood
  y ~ normal(alpha + betaTreat * moistTreat + betaPlot * moistPlot, sigma);
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N)
    y_rep[n] = normal_rng(alpha + betaTreat * moistTreat[n] + betaPlot * moistPlot[n], sigma);
}
