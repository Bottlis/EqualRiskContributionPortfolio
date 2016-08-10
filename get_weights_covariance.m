function result = get_weights_covariance(startDate, endDate)

% change desired tickets here, first must be the benchmark index ticket
tickets = {'^GSPC' ...
'XOM' 'PSX' 'PX' 'LMT' 'UPS' ...
'DAL' 'CMCSA' 'LOW' 'TJX' 'GM' ...
'KO' 'PEP' 'PG' 'JNJ' 'SYK' ...
'BDX' 'MDT' 'BRK-B' 'TRV' 'CCI' ...
'MMC' 'CB' 'ADP' 'EMC' 'ACN' ...
'MSFT' 'MA' 'IBM' 'VZ' 'D'};


% change sectors distribution here, each number indicates starting of a new
% sector except for the last one, last one is just there for the program to
% work
sectors = {2 4 5 8 12 15 19 24 30 31 32}

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

  stockReturns = tick2ret(cell2mat(result),[],'continuous');
  returns = {}
  returns{1} = stockReturns(:,1);
  for i = 1:(length(sectors)-1)
      sectorReturn = zeros(length(stockReturns(:,1)), 1);
      for j = sectors{i}:(sectors{i+1}-1)
          sectorReturn = sectorReturn + stockReturns(:,j);
      end
      returns{end+1} = sectorReturn;
  end
  returns = cell2mat(returns);
  size(returns)
      
      
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

% get sector weights
sectorResult = {};
for i = 1:length(sectors)-1
    fprintf('sector %d: %.2f%%\n', i, weights(i)*100);
    sectorResult{i,1} = i;
    sectorResult{i,2} = weights(i);
end
sectorResult = cell2mat(sectorResult);

% get stock weights given a sector
stockResults = {};
for i = 1:(length(sectors)-1)
    sectorTickets = tickets(sectors{i}:(sectors{i+1}-1));
    stockResults{end+1} = get_weights(sectorTickets);
end

% get final result by sector and ticket weights
result = {};
for i = 1:(length(sectors)-1)
    count = 1;
    for j = sectors{i}:(sectors{i+1}-1)
        sectorPercent = sectorResult(i,2);
        ticket = tickets{j};
        stockResult = stockResults{i};
        ticketPercent = stockResult{count,2};
        result{end+1,1} = ticket;
        result{end,2} = sectorPercent * ticketPercent;
        count = count + 1;
    end
end

end