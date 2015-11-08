# granger
Granger causality for multielectrode array Plexon neuronal recordings.

## About
The script plx_granger_pp is meant for point process models (spike train data). It is based on the [GCPP code by NSRL @ MIT](http://www.neurostat.mit.edu/gcpp) and [its corresponding article](http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1001110).

(The script plx_granger_cont is meant for continuous data and is currently unfinished. It will use [the MVGC Toolbox](http://users.sussex.ac.uk/~lionelb/MVGC/).)

## Instructions

In Matlab, change the working directory to 'granger'. In line 12 of plx_granger_pp, enter the filename of the Plexon data you want to analyze, then run the script.