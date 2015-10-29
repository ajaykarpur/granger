function [beta_new] = glmwin(X,n,ht,k,w)

%================================================================
%                GLM fitting based on submatrices
%================================================================
%
%  This code is made for the case when input matrix X is too large
%  X is partioned into small submatrices of (k x 1)-dimension
%  This code is based on bnlrCG.m (Demba) and 
%
%   References:
%      Dobson, A.J. (1990), "An Introduction to Generalized Linear
%         Models," CRC Press.
%      McCullagh, P., and J.A. Nelder (1990), "Generalized Linear
%         Models," CRC Press.
%
% Input arguments:
%           X: measurement data (# samples x # neurons)
%           n: index number of input (target neuron) to analyze
%          ht: model order (using AIC or BIC)
%           k: one of divisors for K
%           w: duration of non-overlapping spike counting window
%
% Output arguments:
%     beta_new: estimated GLM parameters
%
%================================================================
% Sanggyun Kim
% Neuroscience Statistics Research Lab (BCS MIT)
% April 13. 2009
%================================================================

% Spike counting window
WIN = zeros(ht/w,ht);
for iwin = 1:ht/w
    WIN(iwin,(iwin-1)*w+1:iwin*w) = 1;
end

% CG parameters
cgeps = 1e-3;
cgmax = 30;

% LR parameters
Irmax = 100;
Ireps = 0.05;

% Design matrix, including DC column of all ones (1st or last)
Xnew = X(ht+1:end,:);
[K Q] = size(Xnew);
p = Q*ht/w +1;
for kk = 1:K/k
    for ii = 1:k
        temp = [1];
        for jj = 1:Q
            temp = [temp (WIN*X(ht+(kk-1)*k+ii-1:-1:(kk-1)*k+ii,jj))']; 
        end
        Xsub{kk,1}(ii,1:p) = temp;
    end
end

% Making output matrix Ysub{}
for kk = 1:K/k
    Ysub{kk} = Xnew(k*(kk-1)+1:k*kk,n);
end

% Logistic regression
i = 0;
% Initialization
% P = length(Xsub{1,1});
beta_old = zeros(p,1);
for kk = 1:K/k
    eta{kk} = zeros(k,1);
    for pp = 1:1;
        eta{kk} = eta{kk} + Xsub{kk,pp}*beta_old(p*(pp-1)+1:p*pp);
    end
    musub{kk} = exp(eta{kk})./(1+exp(eta{kk}));
    Wsub{kk} = diag(musub{kk}).*diag(1-musub{kk});
    zsub{kk} = eta{kk} + (Ysub{kk}-musub{kk}).*(1./diag(Wsub{kk}));
end

% Scaled deviance
devold = 0;
for kk = 1:K/k
    devold = devold - 2*(Ysub{kk}'*log(musub{kk})+(1-Ysub{kk})'*log(1-musub{kk}));
end
devnew = 0;
devdiff = abs(devnew - devold);

% Do CG -> beta_new, i.e. solve for beta_new: X'WX*beta_new =
% X'Wz(beta_old) using CG
while (i < Irmax && devdiff > Ireps)
    
    for pp1 = 1:1;
        for pp2 = 1:1;
            A(p*(pp1-1)+1:p*pp1,p*(pp2-1)+1:p*pp2) = zeros(p,p);
            for kk = 1:K/k;
                A(p*(pp1-1)+1:p*pp1,p*(pp2-1)+1:p*pp2) = A(p*(pp1-1)+1:p*pp1,p*(pp2-1)+1:p*pp2) + Xsub{kk,pp1}'*Wsub{kk}*Xsub{kk,pp2};
            end
        end
    end
    %A = A + A' - diag(diag(A));

    for pp1 = 1:1;
        b(p*(pp1-1)+1:p*pp1,1) = zeros(p,1);
        for kk = 1:K/k;
            b(p*(pp1-1)+1:p*pp1,1) = b(p*(pp1-1)+1:p*pp1,1) + Xsub{kk,pp1}'*Wsub{kk}*zsub{kk};
        end
    end

    % Conjugate gradient method for symmetric postive definite matrix A
    beta_new = cgs(A,b,cgeps,cgmax,[],[],beta_old);
    beta_old = beta_new;

    for kk = 1:K/k
        eta{kk} = zeros(k,1);
        for pp = 1:1;
            eta{kk} = eta{kk} + Xsub{kk,pp}*beta_old(p*(pp-1)+1:p*pp);
        end
        musub{kk} = exp(eta{kk})./(1+exp(eta{kk}));
        Wsub{kk} = diag(musub{kk}).*diag(1-musub{kk});
        zsub{kk} = eta{kk} + (Ysub{kk}-musub{kk}).*(1./diag(Wsub{kk}));
    end

    % Scaled deviance
    devnew = 0;
    for kk = 1:K/k
        devnew = devnew - 2*(Ysub{kk}'*log(musub{kk})+(1-Ysub{kk})'*log(1-musub{kk}));
    end
    devdiff = abs(devnew - devold);
    devold = devnew;
    
    i = i+1;
    
end

% % Compute additional statistics
% stats.dfe = 0;
% stats.s = 0;
% stats.sfit = 0;
% stats.covb = inv(A);
% stats.se = sqrt(diag(stats.covb));
% stats.coeffcorr = stats.covb./sqrt((repmat(diag(stats.covb),1,p).*repmat(diag(stats.covb)',p,1)));
% stats.t = 0;
% stats.p = 0;
% stats.resid = 0;
% stats.residp = 0;
% stats.residd = 0;
% stats.resida = 0;