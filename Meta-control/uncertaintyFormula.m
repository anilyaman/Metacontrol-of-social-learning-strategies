% k1 = 1;
% k2 = 99;
% 
% m1 = 1;
% s1 = 0.05;
% m2 = 0.95;
% s2 = 0.2;
function p1 = uncertaintyFormula(m1,s1,k1,m2,s2,k2)

fun = @(y) normpdf((y-m1)./s1).*(normcdf((y-m1)./s1).^(k1-1)).*(normcdf((y-m2)./s2).^k2);
p1 = 1 - (k1/s1) * integral(fun, -inf, inf);





