data {
  int<lower=0> N; // number of cases
  vector[N] y;    // CO2 flux (variate)
  vector[N] x; // initial gravimetric (quadrat moisture) (ALSO ADD MEASUREMENT ERROR IN X)
}

parameters {
  real alpha; // intercept
  real beta;  // slope
  real<lower=0> sigma;  // outcome noise
}

model {
  // Priors 
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
  
  // Likelihood
  y ~ normal(alpha + beta * x, sigma);
}

