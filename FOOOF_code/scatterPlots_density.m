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

    scatter(tmpY,si,"filled", 'green')
    hold on 

end % for / si 

hold on 
title('Gamble Gain')
hold off 


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

    % If only one contact 
    % tmpGL = tmpGL(conRange,:);

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

    tmpGL = fooof_resultsGL(si).peak_params;
    tmpGL = tmpGL(:,1);

    scatter(tmpGL,si,"filled", 'red')
    hold on 

end % for / si 

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

     % If only one contact 
    % tmpAN = tmpAN(conRange,:);

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
 
% Make a AN scatter plot %

for si = 1:width(fooof_resultsAN)

    tmpAN = fooof_resultsAN(si).peak_params;
    tmpAN = tmpAN(:,1);

    scatter(tmpAN, si, "filled", 'blue')
    hold on 

end % for / si 

%% Make an overlaid scatter plot with all 3 trial conditions 
% mostly copied from above and just put into one place 

% GG
for si = 1:width(fooof_resultsGG)

    tmpGG = fooof_resultsGG(si).peak_params;
    tmpGG = tmpGG(:,1);
    tmpGG = round(tmpGG);

    scatter(tmpGG, si, "filled", 'green')
    hold on 

end % for / si 


% GL
for si = 1:width(fooof_resultsGL)

    tmpGL = fooof_resultsGL(si).peak_params;
    tmpGL = tmpGL(:,1);
    tmpGL = round(tmpGL);

    scatter(tmpGL,si,"filled", 'red')
    hold on 

end % for / si 

% AN
for si = 1:width(fooof_resultsAN)

    tmpAN = fooof_resultsAN(si).peak_params;
    tmpAN = tmpAN(:,1);

    scatter(tmpAN, si, "filled", 'blue')
    hold on 

end % for / si 

%%

% Initialize an array to store all frequencies
all_frequencies = [];

% Collect all frequencies from fooof_resultsGG
for si = 1:width(fooof_resultsGG)
    tmpGG = fooof_resultsGG(si).peak_params;
    all_frequencies = [all_frequencies; tmpGG(:,1)];
end

all_frequencies = round(all_frequencies);  % round

% Count the occurrences of each frequency
[unique_frequencies, ~, idx] = unique(all_frequencies);
frequency_counts = accumarray(idx, 1);

% Plot the scatter plot
scatter(unique_frequencies, frequency_counts, 'filled', 'green')

% Add labels and title
xlabel('Frequency')
ylabel('Count')
title('Frequency vs. Count Scatter Plot')


