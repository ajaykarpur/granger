function [GCMAP] = FDR(D,p,ht);

[d,d] = size(D);

% Number of multiple hypothesis tests
m = d*d;

% P-values
for n = 1:d
     P(n,:) = 1 - chi2cdf(D(n,:),ht(n)/2);
end
[Ps,idx] = sort(P(:));

for k = 1:m
    if Ps(k) > k/m*p;
        break;
    end
end
k = k-1;

GCMAP = zeros(size(D));

for ii = 1:k
    if fix(idx(ii)/n) == idx(ii)/n
        GCMAP(n,idx(ii)/n) = 1;
    else
        GCMAP(idx(ii)-fix(idx(ii)/n)*n,fix(idx(ii)/n)+1) = 1;
    end
end