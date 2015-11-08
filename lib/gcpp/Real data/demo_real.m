clear all;

% Load real data of 15 neurons recorded from the M1 of a cat
load data_real_catM1.mat;
% load data_real_nonmove.mat;

% Dimension of X (# Channels x # Samples x # Trials)
[CHN SMP TRL] = size(X);

% To fit GLM models with different history orders
for neuron = 1:CHN
    for ht = 3:3:60                             % history, W=3ms
        [bhat{ht,neuron}] = glmtrial(X,neuron,ht,3);
    end
end

% To select a model order, calculate AIC
for neuron = 1:CHN
    for ht = 3:3:60
        LLK(ht,neuron) = log_likelihood_trial(bhat{ht,neuron},X,ht,neuron);
        aic(ht,neuron) = -2*LLK(ht,neuron) + 2*(CHN*ht/3 + 1);
    end
end

% To plot the AIC 
% for neuron = 1:CHN
%     figure(neuron);
%     plot(aic(3:3:60,neuron));
% end

% Save results
save('result_real_catM1','bhat','aic','LLK');

% Identify Granger causality
% CausalTestTrials;