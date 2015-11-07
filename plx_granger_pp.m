%% Granger causality analysis for Plexon spike data
%
% Ajay Karpur
% Neural Microsystems Lab
% -------------------------------------------------------------------------

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

compression = 1000; % 1 is no compression

numchannels = length(plx.SpikeChannels);
maxtimestamp = 0;
for n=1:numchannels
    if maxtimestamp < plx.SpikeChannels(n).Timestamps(end)
        maxtimestamp = plx.SpikeChannels(n).Timestamps(end);
    end
end

recordinglength = maxtimestamp/plx.WaveformFreq;

ptic(sprintf('\nFormatting data for gcpp using compression of %d...\n', compression));
X = zeros(round(maxtimestamp/compression),numchannels);
for n = 1:numchannels
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

%% analyze data

