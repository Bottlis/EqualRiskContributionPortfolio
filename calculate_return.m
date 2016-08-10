function [dailyReturn, cumulativeReturn] = calculate_return()

load('temp.mat')

weightList = ans;

quarters = {'2012/04/12' '2012/08/01' '2012/11/01' ...
            '2013/02/01' '2013/05/01' '2013/08/01' '2013/11/01' ...
            '2014/02/01' '2014/05/01' '2014/08/01' '2014/11/01' ...
            '2015/02/01' '2015/05/01' '2015/08/01' '2015/11/01' ...
            '2016/02/01' '2016/05/01' '2016/07/25'};
        
% last year to briexit
quarters = {'2015/08/01' '2015/11/01' ...
            '2016/02/01' '2016/05/01' '2016/07/25'};
        
tickets = {'XOM' 'PSX' 'PX' 'LMT' 'UPS' ...
'DAL' 'CMCSA' 'LOW' 'TJX' 'GM' ...
'KO' 'PEP' 'PG' 'JNJ' 'SYK' ...
'BDX' 'MDT' 'BRK-B' 'TRV' 'CCI' ...
'MMC' 'CB' 'ADP' 'EMC' 'ACN' ...
'MSFT' 'MA' 'IBM' 'VZ' 'D'};

tradeList = {};
for t = tickets
    prices = flipud(fetch(yahoo, t{1}, 'Close', '2012/04/12', '2016/7/25'));
    tradeList{end+1} = prices(:,2);
end

tradeList = cell2mat(tradeList);

prices = flipud(fetch(yahoo, 'IWB', 'Close', '2012/04/12', '2016/7/25'));
counter = 1;
baseMoneyRP = 1000;
baseMoneyRU = 1000;
dailyReturn = zeros(2, length(prices));
cumulativeReturn = zeros(2, length(prices));
weights = weightList(:,2);
for i = 1:(length(prices(:,1))-1)
    tradeDate = prices(i,1);
    for j = 1:length(tickets)
        dailyReturn(1,i) = dailyReturn(1,i) + baseMoneyRP * weights{j} * (tradeList(i+1,j)-tradeList(i,j)) / double(tradeList(i,j));
    end
    baseMoneyRP = baseMoneyRP + dailyReturn(1,i);
    cumulativeReturn(1,i) = baseMoneyRP;
    
    if tradeDate >= datenum(quarters{counter}, 'yyyy/mm/dd')
        counter = counter + 1;
        weights = weightList(:,counter);
        
    end
    
    dailyReturn(2,i) = baseMoneyRU * (prices(i+1,2)-prices(i,2)) / double(prices(i,2));
    baseMoneyRU = baseMoneyRU + dailyReturn(2,i)
    cumulativeReturn(2,i) = baseMoneyRU
end

end