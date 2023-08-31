function [fitresult,gof,coeffvals] =fitexpo(Xseries,Yseries)

ft = fittype( 'a*exp(-b*x)+c', 'independent', {'x'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'final';
opts.StartPoint = [1 200 0];
opts.MaxIter = 2000;
% Fit model to data.
[fitresult, gof, opt] = fit(Xseries, Yseries, ft, opts );
coeffvals= coeffvalues(fitresult);

end