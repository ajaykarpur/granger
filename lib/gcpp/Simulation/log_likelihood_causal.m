function [loglike] = log_likelihood_causal(bhat,Y,trigger,ht,neu,w)

% # of neurons
N = size(Y,2);

% Removing trigger neuron
if trigger == 1
    Yc = Y(:,trigger+1:9);
elseif trigger == N
    Yc = Y(:,1:trigger-1);
else
    Yc = [Y(:,1:trigger-1) Y(:,trigger+1:9)];
end

% Size of spike train data
[K,N] = size(Yc);

% Spike counting window
WIN = zeros(ht/w,ht);
for iwin = 1:ht/w
    WIN(iwin,(iwin-1)*w+1:iwin*w) = 1;
end

% Binomial case
loglike = 0;
for k = ht+1:K
    yframe = [1];
    for n = 1:N
        yframe = [yframe; WIN*Yc(k-1:-1:k-ht,n)];
    end
    eta = bhat'*yframe;
    p = exp(eta)/(1+exp(eta));
    loglike = loglike + Y(k,neu)*log(p) + (1-Y(k,neu))*log(1-p);
end