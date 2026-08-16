function getTfromP(t,n)

v = n-1;
% 
 tdist2T = @(t,v) (1-betainc(v/(v+t^2),v/2,0.5));    % 2-tailed t-distribution
 tdist1T = @(t,v) 1-(1-tdist2T(t,v))/2;              % 1-tailed t-distribution

t2T =  1- tdist2T(t,v);    % 2-tailed t-distribution
t1T =  1- tdist1T(t,v);              % 1-tailed t-distribution

disp(sprintf('two-tailed p = %0.5f )%0.2e',t2T,t2T));
disp(sprintf('one-tailed p = %0.5f )%0.2e',t1T,t1T));

end