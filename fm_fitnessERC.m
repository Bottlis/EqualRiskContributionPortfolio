
% ERC portfolio fitness function.
%  more technical details can be found on Roncalli web page 
%  http://www.thierry-roncalli.com/download/erc-slides.pdf  

% Farid Moussaoui
% farid.moussaoui at gmail.com
% 

% This is the best implementation I found 

function fval = fm_fitnessERC(covMat, x) 
  
  N = size(covMat,1) ;  
  
  y = x .* (covMat*x) ; 
  
  fval = 0 ; 
  
  for i = 1:N
    for j = i+1:N
      xij  = y(i) - y(j) ; 
      fval = fval + xij*xij ; 
    end 
  end
  
  % fval = 2*fval ;
  
  fval = sqrt(fval) ;
  
end
