data {
  int<lower=0> N;         // number of cases
  int<lower=0> K;         // number of columns
  int<lower=0> J;         // number of intercepts
  vector[N] y;            // CO2 flux (variate)
  matrix[N, K] X;         // Predictor variables 
  int site[N];            // Grouping factor
}

parameters {
  vector[J] alpha;      // vector of intercepts
  vector[K] beta;       // vector of slopes
  real<lower=0> sigma;  // outcome noise
}

model {
  // Priors 
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
  
  // Likelihood
  for (n in 1:N)
    y[n] ~ normal(alpha[site[n]] + X[n,] * beta, sigma);
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N)
    y_rep[n] = normal_rng(alpha[site[n]] + X[n,] * beta, sigma);
}
