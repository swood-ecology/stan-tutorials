data {
  int<lower=0> N;         // number of cases
  int<lower=0> K;         // number of columns
  vector[N] y;            // CO2 flux (variate)
  matrix[N, K] X;         // Predictor variables   
}

parameters {
  real alpha; // intercept
  vector[K] beta;  // vector of slopes
  real<lower=0> sigma;  // outcome noise
}

model {
  // Priors 
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
  
  // Likelihood
  y ~ normal(alpha + X * beta, sigma);
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N)
    y_rep[n] = normal_rng(alpha + X[n,] * beta, sigma);
}
