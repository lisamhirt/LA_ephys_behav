% Use allLFPtab that was created from FOOOF_start_v1

% Find where all outcomes and all trials (GG/GL/AN) occured %

% ---- Pull out the outcome epoch for all trial types ---- %
% find where all outcomes occured %
% Find the rows where the EpochID column is "Outcome"
rowsWithOutcome = strcmp(allLFPtab.EpochID, "Outcome");

% Extract those rows from the table
% All Outcome rows in a table 
tmpOut = allLFPtab(rowsWithOutcome, :); % tmpOut is now the table that has all the outcome epochs in it

% FOOOF Settings - for all fooofs 
settings = struct();
f_range = [1,40];
conRange = 1:3;

%% Gamble Gain

% Get GG data out %
% Extract GG rows
GGidx = tmpOut.GambleGain;
GGTab = tmpOut(GGidx,:);

% Get out GG ephys and do PSD
GGEphys = []; % empty holder for ephys

for gg = 1:height(GGTab)

    tmpGG = GGTab.Ephys{gg};
    tmpGG = mean(tmpGG(conRange,:)); % average tmp ephys

    % If only one contact 
    % tmpGG = tmpGG(conRange,:);

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpGG,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    GGEphys = [GGEphys psd];

end % for / gg

% Transpose, to make inputs row vectors
freqsGG = freqs'; 

% Run FOOOF % 

% Run FOOOF across group of power spectra 
fooof_resultsGG = fooof_group(freqsGG, GGEphys, f_range, settings);
 
% Make a GG scatter plot %

for si = 1:width(fooof_resultsGG)

    tmpY = fooof_resultsGG(si).peak_params;
    tmpY = tmpY(:,1);

    scatter(si, tmpY,"filled")
    hold on 

end % for / si 

hold on 
title('Gamble Gain')
hold off 
