function result = get_weights_normrnd()

% change desired tickets here, first must be the benchmark index ticket
tickets = {'^GSPC' ...
           'XOM' 'XOM' 'XOM' 'PSX' 'PSX' 'PSX' ...
           'PX' 'PX' 'PX' 'PX' 'PX' 'LMT' 'LMT' ...
           'UPS' 'UPS' 'DAL' 'DAL' 'CMCSA' 'LOW' ...
           'TJX' 'TJX' 'GM' 'GM' 'KO' 'KO' 'PEP' 'PEP' ...
           'PG' 'PG' 'JNJ' 'JNJ' 'SYK' 'BDX' 'MDT' 'MDT' ...
           'BRK-B' 'TRV' 'TRV' 'CCI' 'MMC' 'CB' 'ADP' ...
           'EMC' 'ACN' 'MSFT' 'MA' 'IBM' ...
           'VZ' 'VZ' 'VZ' 'VZ' 'VZ' 'VZ' ...
           'D' 'D' 'D' 'D' 'D' 'D'};

% specify start and end date in yyyy/mm/dd format
startDate = '2014/01/01';
endDate = '2016/01/01';

% specify data connection
connection = yahoo;

% start generating dataset in desired format:
result = {};
benchmark = tickets{1};
prices = fetch(connection, benchmark, 'Close', startDate, endDate);
result{1} = flipud(prices(:,2));
for i = 2:length(tickets)
    ticket = tickets{i};
    fprintf('getting prices for ticket %s\n', ticket);
    prices = fetch(connection, ticket, 'Close', startDate, endDate);
    priceOnly = flipud(prices(:,2));
    if strcmp(ticket, tickets{i-1}) == 1
        % randomnize each ticket's individual price by a normal randomnizer
        for i = 1:length(priceOnly)
            priceOnly(i) = normrnd(priceOnly(i), priceOnly(i)/20);
        end
    end
    result{end+1} = priceOnly;
        
end
tickets = tickets(2:end);

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

% aggregate dummy stock tickets and produce output
result = {};
counter = 1;
result{1,1} = tickets{1};
result{1,2} = weights(1);
for i = 2:length(tickets)
    fprintf('ticket %s: %.2f%%\n', tickets{i}, weights(i)*100);
    if strcmp(tickets{i},tickets{i-1})==1
        result{counter,2} = result{counter,2} + weights(i)
    else
        counter = counter + 1
        result{counter,1} = tickets{i};
        result{counter,2} = weights(i);
    end
end

end
    