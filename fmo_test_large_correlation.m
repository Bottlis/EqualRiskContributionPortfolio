  N = 500 ;

  riskW = 1/N * ones(N, 1) ;
  
  % generate random correlation matrix with random eigenvalues 
  % from a uniform distribution
  
  start = tic ;
    
  covMat = gallery('randcorr',N) ;
    
  elapsedTimeCorrel = toc(start) ;
  
  fprintf(' Elapsed time for correlation matrix generation: %f seconds\n', ...
          elapsedTimeCorrel)
    
  Niter = 5000 ; tol = 1.e-8 ; 
  
  start = tic ; 
    [u, iters, err] = fmo_rpGaussSeidel(covMat, riskW, Niter, tol) ; 
  elapsedTime = toc(start) ; 
  
  fprintf(' Elapsed time for the RP solution: %f seconds\n', elapsedTime)
  
