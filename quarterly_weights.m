function result = quarterly_weights()

% set quarterly review date to first day of May, August, November,
% February, except the first date is 4/12 becuase it's the earlist date all
% stocks are listed. These four months are the MSCI index review months,
% simly copied lol.
quarters = {'2012/4/12' '2012/8/1' '2012/11/1' ...
            '2013/2/1' '2013/5/1' '2013/8/1' '2013/11/1' ...
            '2014/2/1' '2014/5/1' '2014/8/1' '2014/11/1' ...
            '2015/2/1' '2015/5/1' '2015/8/1' '2015/11/1' ...
            '2016/2/1' '2016/5/1' '2016/7/25'};

% last year to briexit
quarters = {'2015/05/01' '2015/08/01' '2015/11/01' ...
            '2016/02/01' '2016/05/01' '2016/07/25'};
        
fprintf('getting weights from %s to %s\n', quarters{1}, quarters{2});
result = get_weights_covariance(quarters(1), quarters(2));

for i = 2:(length(quarters)-1)
    fprintf('getting weights from %s to %s\n', quarters{i}, quarters{i+1});
    weights = get_weights_covariance(quarters(i), quarters(i+1));
    result(:,i+1) = weights(:,2);
end

save('quarterWeights.mat', 'result');

end