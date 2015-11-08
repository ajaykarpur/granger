%% Granger causality analysis for Plexon spike data
%
% Ajay Karpur
% Neural Microsystems Lab
% -------------------------------------------------------------------------

clear;clc;

addpath(genpath(pwd))

% enter filename for data here:
filename = 'data/GAPDH baseline.plx';

plx = readPLXFileC(filename,'spikes');

% check if file has spike data
if ~isfield(plx.SpikeChannels, 'Timestamps')
    fprintf('\nThis file has no spike data. Please select another .plx file.\n')
    fprintf('Alternatively, you may try using start_granger.m for continuous data.\n\n')
    return
end

%% format data for gcpp
% *WARNING:* This step can take a lot of time and memory!
% If you run out of memory, increase the compression value.
% (Compression of more than 100 tends to be lossy.)

compression = 400000; % 1 is no compression

N = length(plx.SpikeChannels);
maxtimestamp = 0;
for n=1:N
    if maxtimestamp < plx.SpikeChannels(n).Timestamps(end)
        maxtimestamp = plx.SpikeChannels(n).Timestamps(end);
    end
end

L = round(maxtimestamp/compression);
recordinglength = maxtimestamp/plx.WaveformFreq;

ptic(sprintf('\nFormatting data for gcpp using compression of %d...\n', compression));
X = zeros(L,N);

for n = 1:N
    i = 1; j = 1;
    while (i < length(plx.SpikeChannels(n).Timestamps))
        if (j == round(plx.SpikeChannels(n).Timestamps(i)/compression))
            X(j,n) = 1;
            i = i+1;
            j = j+1;
        elseif (j > round(plx.SpikeChannels(n).Timestamps(i)/compression))
            i = i+1;
        else
            X(j,n) = 0;
            j = j+1;
        end
    end
end
ptoc;

%% fit models and select model order

% To fit GLM models with different history orders
ptic('\nFitting GLM...\n');
for n = 1:N                            % neuron
    for ht = 2:2:10                         % history, when W=2ms
        [bhat{ht,n}] = glmwin(X,n,ht,200,2);
    end
end
ptoc;

% To select a model order, calculate AIC
ptic('\nCalculating AIC...\n');
for n = 1:N
    for ht = 2:2:10
        LLK(ht,n) = log_likelihood_win(bhat{ht,n},X,ht,n,2); % Log-likelihood
        aic(ht,n) = -2*LLK(ht,n) + 2*(N*ht/2 + 1);                % AIC
    end
end
ptoc;

% To plot AIC 
for neuron = 1:N
    figure(neuron);
    plot(aic(2:2:10,neuron));
end

% Save results
save('models','bhat','aic','LLK');

%% Granger causality

% Re-optimizing a model after excluding a trigger neuron's effect and then
% Estimating causality matrices based on the likelihood ratio
ptic('\nReoptimizing models and estimating causality matrices...\n');
for target = 1:N
    LLK0(target) = LLK(ht(target),target);              % Likelihood of full model
    % LLK0(target) = log_likelihood_win(bhat{ht(target),target},X,ht(target),target);
    for trigger = 1:N
        % MLE after excluding trigger neuron
        [bhatc{target,trigger}] = glmcausal(X,target,trigger,ht(target),200,2);
        
        % Log likelihood obtained using a new GLM parameter and data, which exclude trigger
        LLKC(target,trigger) = log_likelihood_causal(bhatc{target,trigger},X,trigger,ht(target),target,2);
        
        % Log likelihood ratio
        LLKR(target,trigger) = LLKC(target,trigger) - LLK0(target);
        
        % Sign (excitation and inhibition) of interaction from trigger to target
        % Averaged influence of the spiking history of trigger on target
        SGN(target,trigger) = sign(sum(bhat{ht(target),target}(ht(target)/2*(trigger-1)+2:ht(target)/2*trigger+1)));
    end
end
ptoc;

ptic('\nCalculating Granger causality matrix...\n');
Phi = -SGN.*LLKR; % Granger causality matrix
ptoc;

ptic('\nCalculating causal connectivity matrix...\n');
D = -2*LLKR; % Deviance difference
alpha = 0.05;
for ichannel = 1:N
    temp1(ichannel,:) = D(ichannel,:) > chi2inv(1-alpha,ht(ichannel)/2);
end
Psi1 = SGN.*temp1; % Causal connectivity matrix, Psi, w/o FDR
ptoc;

% % Causal connectivity matrix, Psi, w/ FDR
% fdrv = 0.05;
% temp2 = FDR(D,fdrv,ht);
% Psi2 = SGN.*temp2;

% Plot the results
figure(1);imagesc(Phi);xlabel('Triggers');ylabel('Targets');
figure(2);imagesc(Psi1);xlabel('Triggers');ylabel('Targets');
% figure(3);imagesc(Psi2);xlabel('Triggers');ylabel('Targets');