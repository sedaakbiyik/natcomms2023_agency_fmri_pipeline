function [pID, p_masked] = fdr(pvals, q, fdrType)


if nargin < 3, fdrType = 'parametric'; end;
if isempty(pvals), pID = []; return; end;
p = sort(pvals(:));
V = length(p);
%V = length(p(~isnan(p)));
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

if nargin < 2
    pID = ones(size(pvals));
    thresholds = exp(linspace(log(0.1),log(0.000001), 100));
    for index = 1:length(thresholds)
        [tmp p_masked] = fdr(pvals, thresholds(index));
        pID(p_masked) = thresholds(index);
    end;
else
    if strcmpi(fdrType, 'parametric')
        pID = p(max(find(p<=I/V*q/cVID))); % standard FDR
    else
        pID = p(max(find(p<=I/V*q/cVN)));  % non-parametric FDR
    end;
end;
if isempty(pID), pID = 0; end;

if nargout > 1
    p_masked = pvals<=pID;
end