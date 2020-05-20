data {
  int<lower=0> N; // number of cases
  vector[N] y;    // CO2 flux (variate)
  vector[N] x;    // initial gravimetric (quadrat moisture) (ALSO ADD MEASUREMENT ERROR IN X)
  real<lower=0> mu;  // input prior on parameter mean
  real<lower=0> tau;    // input prior on parmater sd
}

parameters {
  real alpha; // intercept
  real beta;  // slope
  real<lower=0> sigma;  // outcome noise
}

model {
  // Priors 
  alpha ~ normal(0, 10);
  beta ~ normal(mu, tau);
  sigma ~ cauchy(0, 5);
  
  // Likelihood
  y ~ normal(alpha + beta * x, sigma);
}

generated quantities {
  vector[N] y_rep;
  // No vectorized form for this
  for (n in 1:N)
    y_rep[n] = normal_rng(alpha + beta * x[n], sigma);
}
