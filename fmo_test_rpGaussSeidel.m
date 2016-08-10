%% 

  sigma = [ 0.1; 0.2; 0.3; 0.4] ; 
  
  rho = [ 1.0 0.8  0.0  0.0 ; 
          0.8 1.0  0.0  0.0 ; 
          0.0 0.0  1.0 -0.5 ; 
          0.0 0.0 -0.5  1.0 
        ] ; 
  
  expCov = corr2cov(sigma, rho) ; 
  
  riskW = [0.4; 0.3; 0.1; 0.2] ;
  
  Niter = 100 ;
  tol = 10^(-15) ; 
  
  [sol, iters, err] = fmo_rpGaussSeidel(expCov, riskW, Niter, tol) ; 
  
  s  = sqrt(sol'*expCov*sol)  ;
  c  = sol .* ( expCov*sol/sqrt(sol'*expCov*sol) );
  si = c / s; 
 