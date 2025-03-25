%% FOOOF Matlab Wrapper Example - Single PSD
%
% This example computes an example power spectrum model for a single
% power spectrum, and prints out the results.
%

%% Run Example

% Load data
% load('data/ch_dat_one.mat');

% From data that was cut down to min size and meaned 
% This data violates the 1/f power law somehow 
GLoutShort = epochEphys.GLOut; 
gamOut = epochEphys.GamOut;
GGoutShort = epochEphys.GGOut;

% Only cleaned ephys
% Gamble gain 
GGout = allLFPtab{4,"Ephys"};
GGout = cell2mat(GGout);
GGoutMean = mean(GGout); % this isn't working - ask JAT %

% Use the first two lines of data until Mean can work 
GGoutMean = mean(GGout(1:2,:));

% Gamble Loss 
GLout = allLFPtab{20, "Ephys"};
GLout = cell2mat(GLout);
GLoutMean = mean(GLout(1:2,:));

% Alternative Outcome 
ANout = allLFPtab{12, "Ephys"};
ANout = cell2mat(ANout);
ANoutMean = mean(ANout(1:2,:));



s_rate = 500; % my sampling rate is 500

% Calculate a power spectrum with Welch's method

% Lisa's Notes about pwelch % 
% [pxx, f] = pwelch(x, window, overlap, nfft, fs);
% overlap: 50 % overlap is the recommended place to start  
% nfft: nfft is the length of the FFT (Fast Fourier Transform) used to calculate
% the PSD. The default nfft is the greater of 256 or the next power of 2 
% greater than the length of the segments

% Original example from FOOOF 
% [psd, freqs] = pwelch(ch_dat_one, 500, [], [], s_rate); 

% QUESTION - how do you pick a window? i have 25 because that worked with gamOut
% [psd, freqs] = pwelch(gamOut, 25, [], [], s_rate); 
[psd, freqs] = pwelch(GGoutShort, 25, [], [], s_rate); 
[psdGG, freqsGG] = pwelch(GGoutMean, 100, [], [], s_rate); 

% Test different window lengths
% the longer the window the more spikey it looks and not as smooth 
[psdT, freqsT] = pwelch(GGoutMean, 200, [], [], s_rate); 


% Transpose, to make inputs row vectors
freqs = freqs';
psd = psd';

freqsGG = freqsGG';
psdGG = psdGG';

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

fooof_resultsGG = fooof(freqsGG, psdGG, f_range, settings, true);

% Plot the resulting model
fooof_plot(fooof_results)
figure;
fooof_plot(fooof_resultsGG)


%% Test different overlapping window sizes 
% 50% overlap and [] outputs look the same 
% 12.5 % (what they did in the paper) looks different than [] but similar
% to when I increase the window length 
% [pxx, f] = pwelch(x, window, overlap, nfft, fs);
pwelch(GGoutMean, 100, 12.5, [], s_rate);
% hold on 
% title('50% overlap')
% hold off 

figure;
pwelch(GGoutMean, 100, [], [], s_rate); 

%% Test GG out, GL out, and Alt out to each other 
% PSD 
[psdGG, freqsGG] = pwelch(GGoutMean, 100, [], [], s_rate); 
[psdGL, freqsGL] = pwelch(GLoutMean, 100, [], [], s_rate); 
[psdAN, freqsAN] = pwelch(ANoutMean, 100, [], [], s_rate); 

% Transpose, to make inputs row vectors
freqsGL = freqsGL';
psdGL = psdGL';

freqsGG = freqsGG';
psdGG = psdGG';

freqsAN = freqsAN';
psdAN = psdAN';


% Run FOOOF, also returning the model
fooof_resultsGL = fooof(freqsGL, psdGL, f_range, settings, true);
fooof_resultsGG = fooof(freqsGG, psdGG, f_range, settings, true);
fooof_resultsAN = fooof(freqsAN, psdAN, f_range, settings, true);

% Plot the resulting model
fooof_plot(fooof_resultsGL)
fooof_plot(fooof_resultsGG)
fooof_plot(fooof_resultsAN)


