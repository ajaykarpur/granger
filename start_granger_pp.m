filename = 'data/GAPDH baseline.plx';

startup;

plx = readPLXFileC(filename);

if isempty(plx.SpikeChannels)
    fprintf('\nThis file has no spike data. Please select another .plx file.\n')
    fprintf('Alternatively, you may try using start_granger.m for continuous data.\n\n')
end