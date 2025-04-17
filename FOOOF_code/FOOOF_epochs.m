% Use allLFPtab that was created from FOOOF_start_v1

% I loaded CLASE018_LAMY 

% ---- Pull out epochs for all trial types ---- %

% Find the rows where the EpochID column is "Outcome"
% Don't do decision epoch 
rowsWithStart = strcmp(allLFPtab.EpochID, "Start");
rowsWithResponse = strcmp(allLFPtab.EpochID, "Response");
rowsWithOutcome = strcmp(allLFPtab.EpochID, "Outcome");

% Extract those rows from the table and create a new table 
tmpStart = allLFPtab(rowsWithStart, :); % start epoch
tmpResp = allLFPtab(rowsWithResponse, :); % Response epoch 
tmpOut = allLFPtab(rowsWithOutcome, :); % tmpOut is now the table that has all the outcome epochs in it

% FOOOF Settings - for all fooofs 
settings = struct();
f_range = [1,40];
conRange = 1:2; % move up in code 

tmpPartID = 'CLASE018';
tmpHemi = 'L';
tmpBrainArea = 'AMY';

% Initalize table
partTab = table('Size', [0,7], 'VariableTypes',{'string', 'string', 'string', ...
    'string','string','double', 'double'},...
    'VariableNames',{'partID', 'Hemi', 'BrainArea', 'TrialType', 'EpochType','ephysCell', 'powerCell'});

%% Start Epoch %%

% ---- Start - Alternative ---- % 
tmpStartANidx = tmpStart.Alternative;
tmpStartANtab = tmpStart(tmpStartANidx,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpStartANtab)

    tmpST = tmpStartANtab.Ephys{si};

     if sum(conRange) >= 2
    tmpST = mean(tmpST(conRange,:)); % average tmp ephys

     else 
    % If only one contact 
    tmpST = tmpST(conRange,:);
       end % if else

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si 

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('AN'), tmpLength, 1);
EpochType = repmat(string('Start'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables

%%
% ---- Start - Gamble Gain ---- % 
tmpStartGGidx = tmpStart.GambleGain;
tmpStartGGtab = tmpStart(tmpStartGGidx,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpStartGGtab)

    tmpST = tmpStartGGtab.Ephys{si};

    if sum(conRange) >= 2
    tmpST = mean(tmpST(conRange,:)); % average tmp ephys

    else 
    % If only one contact 
    tmpST = tmpST(conRange,:);
    end 

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si 

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('GG'), tmpLength, 1);
EpochType = repmat(string('Start'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables

%% 
% ---- Start - Gamble Loss ---- % 
tmpStartGLidx = tmpStart.GambleLoss;
tmpStartGLtab = tmpStart(tmpStartGLidx,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpStartGLtab)

    tmpST = tmpStartGLtab.Ephys{si};

    if sum(conRange) >= 2
    tmpST = mean(tmpST(conRange,:)); % average tmp ephys

    else 
    % If only one contact 
    tmpST = tmpST(conRange,:);
    end 

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si 

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('GL'), tmpLength, 1);
EpochType = repmat(string('Start'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables

%% Response %% 

% ---- Response - Alternative ---- % 
tmpRespIDX = tmpResp.Alternative;
tmpRespANtab = tmpResp(tmpRespIDX,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpRespANtab)

    tmpST = tmpRespANtab.Ephys{si};
    
    if sum(conRange) >= 2

    tmpST = mean(tmpST(conRange,:)); % average tmp ephys

    else 
    % If only one contact 
    tmpST = tmpST(conRange,:);
    end 

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si 

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('AN'), tmpLength, 1);
EpochType = repmat(string('Response'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables



% ---- Response - Gamble Gain  ---- % 
tmpRespIDX = tmpResp.GambleGain;
tmpRespGGtab = tmpResp(tmpRespIDX,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpRespGGtab)

    tmpST = tmpRespGGtab.Ephys{si};

       if sum(conRange) >= 2
    tmpST = mean(tmpST(conRange,:)); % average tmp ephys

       else 
    % If only one contact 
    tmpST = tmpST(conRange,:);

       end 

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si 

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('GG'), tmpLength, 1);
EpochType = repmat(string('Response'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables


% ---- Response - Gamble Loss  ---- % 
tmpRespIDX = tmpResp.GambleLoss;
tmpRespGLtab = tmpResp(tmpRespIDX,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpRespGLtab)

    tmpST = tmpRespGLtab.Ephys{si};

    if sum(conRange) >= 2

    tmpST = mean(tmpST(conRange,:)); % average tmp ephys

    else
    % If only one contact 
    tmpST = tmpST(conRange,:);
    end

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si 

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('GL'), tmpLength, 1);
EpochType = repmat(string('Response'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables


%% Outcome %% 

% ---- Outcome - Alternative ---- % 
tmpOutcomeIDX = tmpOut.Alternative;
tmpOutANtab = tmpOut(tmpOutcomeIDX,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpOutANtab)

    tmpST = tmpOutANtab.Ephys{si};

    if sum(conRange) >= 2

        tmpST = mean(tmpST(conRange,:)); % average tmp ephys

    else
        % If only one contact
        tmpST = tmpST(conRange,:);
    end % if else

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('AN'), tmpLength, 1);
EpochType = repmat(string('Outcome'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables


% ---- Outcome - Gamble Gain ---- % 
tmpOutcomeIDX = tmpOut.GambleGain;
tmpOutGGtab = tmpOut(tmpOutcomeIDX,:);

STpsd = []; % holder for start PSD 

for si = 1:height(tmpOutANtab)

    tmpST = tmpOutANtab.Ephys{si};

    if sum(conRange) >= 2

        tmpST = mean(tmpST(conRange,:)); % average tmp ephys

    else
        % If only one contact
        tmpST = tmpST(conRange,:);
    end % if else

    % PSD - pwelch
    [psd, freqs] = pwelch(tmpST,hamming(128), 64, 512, 500);

    % Save psd, freqs is the same no matter what
    STpsd = [STpsd psd];

end % for / si

% Transpose, to make inputs row vectors
freqsST = freqs'; 

% Run FOOOF % 
% Run FOOOF across group of power spectra 
fooof_results = fooof_group(freqsST, STpsd, f_range, settings);

% Get peak ephys and power from foof %
ephysCell = [];
powerCell = [];

for pii = 1:width(fooof_results)

    % Peak Params 
    peakParams = fooof_results(pii).peak_params;
    peakParams2 = peakParams(:,1);

    % Add to cell
    ephysCell = [ephysCell; peakParams2];

    % Power Params 
    powerParams = peakParams(:,2);

    % Add to cell 
    powerCell = [powerCell; powerParams];

end % for / pi 

% make table %
tmpLength = length(ephysCell);

partID = repmat(tmpPartID,tmpLength,1);
Hemi = repmat(tmpHemi, tmpLength,1);
BrainArea = repmat(tmpBrainArea, tmpLength, 1);
TrialType = repmat(string('AN'), tmpLength, 1);
EpochType = repmat(string('Outcome'), tmpLength, 1);

tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

partTab = vertcat(partTab, tmpTAB); % combine tables