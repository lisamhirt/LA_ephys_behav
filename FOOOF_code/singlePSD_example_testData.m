%% FOOOF Matlab Wrapper Example - Single PSD
%
% This example computes an example power spectrum model for a single
% power spectrum, and prints out the results.
%

%% Run Example

% Load data
% load('data/ch_dat_one.mat');

GLout = epochEphys.GLOut; 
gamOut = epochEphys.GamOut;

GGout = allLFPtab{4,"Ephys"};
GGout = cell2mat(GGout);

GGoutMean = mean(GGout); % this isn't working - ask JAT 

% Use the first line of data until Mean can work 
GGoutTMP = GGout(1,:);

s_rate = 500; % my sampling rate is 500

% Calculate a power spectrum with Welch's method
% [psd, freqs] = pwelch(ch_dat_one, 500, [], [], s_rate);
% QUESTION - how do you pick a window? i have 25 because that worked with gamOut
[psd, freqs] = pwelch(gamOut, 25, [], [], s_rate);


% Transpose, to make inputs row vectors
freqs = freqs';
psd = psd';

% FOOOF settings
settings = struct();  % Use defaults
f_range = [1, 30];

% Run FOOOF
fooof_results = fooof(freqs, psd, f_range, settings);

% Print out the FOOOF Results
fooof_results


%% PLOT FOOOF
% FOOOF settings
settings = struct();  % Use defaults
f_range = [1, 30];

% Run FOOOF, also returning the model
fooof_results = fooof(freqs, psd, f_range, settings, true);

% Plot the resulting model
fooof_plot(fooof_results)