% Use allLFPtab that was created from FOOOF_start_v1

% ---- Pull out the outcome epoch for all trial types ---- %

% Create a column that has the order number in it %

% Create an array with numbers 1 through 135 that are repeated 4 times each
% tmpCol = repmat(1:135, 4, 1);
% % Reshape the array to be a single row
% tmpCol = tmpCol(:);
% % Make tmpCol a table
% tmpCol = table(tmpCol,'VariableNames',{'TrialNum'});
% % Add tmpCol to allLFPtab
% allLFPtab = [allLFPtab tmpCol];

% Find where all outcomes and all trials (GG/GL/AN) occured %

% find where all outcomes occured %
% Find the rows where the EpochID column is "Outcome"
rowsWithOutcome = strcmp(allLFPtab.EpochID, "Outcome");

% Extract those rows from the table
% All Outcome rows in a table 
tmpOut = allLFPtab(rowsWithOutcome, :); % tmpOut is now the table that has all the outcome epochs in it

% FOOOF Settings - for all fooofs 
settings = struct();
f_range = [1,40];
conRange = 1:2;


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
%%
figure;
%% Gamble Loss 

% Get GL data out %
% Extract GL rows
GLidx = tmpOut.GambleLoss;
GLTab = tmpOut(GLidx,:);

% Get out GL ephys and do PSD
GLEphys = []; % empty holder for ephys

for gl = 1:height(GLTab)

    tmpGL = GLTab.Ephys{gl};
    tmpGL = mean(tmpGL(conRange,:)); % average tmp ephys

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpGL,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    GLEphys = [GLEphys psd];

end % for / gl

% Transpose, to make inputs row vectors
freqsGL = freqs'; 

% Run FOOOF % 

% Run FOOOF across group of power spectra 
fooof_resultsGL = fooof_group(freqsGL, GLEphys, f_range, settings);
 
% Make a GL scatter plot %

for si = 1:width(fooof_resultsGL)

    tmpY = fooof_resultsGL(si).peak_params;
    tmpY = tmpY(:,1);

    scatter(si, tmpY,"filled")
    hold on 

end % for / si 

hold on 
title('Gamble Loss')
hold off 
%%
figure;
%% Alternative 
% Get AN data out %
% Extract AN rows
ANidx = tmpOut.Alternative;
ANTab = tmpOut(ANidx,:);

% Get out GL ephys and do PSD
ANEphys = []; % empty holder for ephys

for an = 1:height(ANTab)

    tmpAN = ANTab.Ephys{an};
    tmpAN = mean(tmpAN(conRange,:)); % average tmp ephys

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpAN,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    ANEphys = [ANEphys psd];

end % for / gl

% Transpose, to make inputs row vectors
freqsAN = freqs'; 

% Run FOOOF % 

% Run FOOOF across group of power spectra 
fooof_resultsAN = fooof_group(freqsAN, ANEphys, f_range, settings);
 
% Make a GL scatter plot %

for si = 1:width(fooof_resultsAN)

    tmpY = fooof_resultsAN(si).peak_params;
    tmpY = tmpY(:,1);

    scatter(si, tmpY,"filled")
    hold on 

end % for / si 

hold on 
title('alternative')
hold off