function [loglike] = log_likelihood_win(bhat,Y,ht,neu,w);

% Size of spike train data
[K,N] = size(Y);

% Counting window
WIN = zeros(ht/w,ht);
for iwin = 1:ht/w
    WIN(iwin,(iwin-1)*w+1:iwin*w) = 1;
end

% Binomial case
loglike = 0;
for k = ht+1:K                     % for k = 10+1:K
    yframe = [1];
    for n = 1:N
        yframe = [yframe; WIN*Y(k-1:-1:k-ht,n)];
    end
    eta = bhat'*yframe;
    p = exp(eta)/(1+exp(eta));
    loglike = loglike + Y(k,neu)*log(p) + (1-Y(k,neu))*log(1-p);
end