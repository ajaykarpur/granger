%% Granger causality analysis for continuous Plexon data
%
% *WARNING:* This script is unfinished and not yet functional!
%
% Ajay Karpur
% Neural Microsystems Lab
% -------------------------------------------------------------------------

addpath(genpath(pwd))

% enter filename for data
filename = 'data/GAPDH baseline.plx';

startup;

plx = readPLXFileC(filename,'continuous');

% check if file has continuous data
if isempty(plx.ContinuousChannels)
    fprintf('\nThis file has no continuous data. Please select another .plx file.\n')
    fprintf('Alternatively, you may try using start_granger_pp.m for a point process model.\n\n')
    return
end

%% MVGC Parameters

ntrials   = 1;      % number of trials
nobs      = 1000;   % number of observations per trial
nvars     = plx.NumContChannels;

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'AIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 20;     % maximum model order for model order estimation

acmaxlags = [];     % maximum autocovariance lags (empty for automatic calculation)

tstat     = 'F';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = plx.WaveformFreq;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)

%% Load data

X = plx.ContinuousChannels;