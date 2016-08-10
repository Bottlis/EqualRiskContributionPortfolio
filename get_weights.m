function result = get_weights(tickets)

% change desired tickets here, first must be the benchmark index ticket
tickets = ['^GSPC' tickets]

% specify start and end date in yyyy/mm/dd format
startDate = '2014/01/01';
endDate = '2016/01/01';

% specify data connection
connection = yahoo;

% start generating dataset in desired format:
result = {};
for ticket = tickets
    fprintf('getting prices for ticket %s\n', ticket{1});
    prices = fetch(connection, ticket{1}, 'Close', startDate, endDate);
    result{end+1} = flipud(prices(:,2));
end

% ERC portfolio construction

tic

  returns = tick2ret(cell2mat(result),[],'continuous');
  numReturns = size(returns,1)
  a = cov(returns)
  [annualRet, annualCov] = geom2arith(mean(returns),cov(returns),numReturns);
  
  annualRet = annualRet';
  annualStd = sqrt(diag(annualCov));
  
  indexRet = annualRet(1) ;            % DJIA return 
  indexStd = annualStd(1) ;            % DJIA standard deviation 
  
  expRet  = annualRet(2:end) ;         % Stocks return 
  expStd  = annualStd(2:end) ;         % Stocks std
  expCov  = annualCov(2:end,2:end) ;   % Stocks covariance  
  
  Ndim = length(expRet) ; 
  
  Aeq = ones(1,Ndim);
  Beq = 1;
  
  lbnds = zeros(Ndim,1);
  ubnds = ones (Ndim,1);

  qoptions = optimset('Display', 'iter', ...
                      'Algorithm','interior-point', ...
                      'MaxFunEvals', 500000, ...
                      'TolFun', 1e-20) ; 
  
  n1 = 1.0/Ndim;
  
  w0 = repmat(n1, Ndim, 1) ; % w0 = n1*ones(Ndim,1); 
  
  NLLfunction = @(x) fm_fitnessERC(expCov, x) ;
  
  [weights, fval, sqpExit] = fmincon(NLLfunction, w0, ...
                                     [], [], Aeq, Beq, lbnds, ubnds, [], ...
                                     qoptions) ;
toc

result = {};
tickets = tickets(2:end);
for i = 1:length(tickets)
    fprintf('ticket %s: %.2f%%\n', tickets{i}, weights(i)*100);
    result{i,1} = tickets{i};
    result{i,2} = weights(i);
end

end
    