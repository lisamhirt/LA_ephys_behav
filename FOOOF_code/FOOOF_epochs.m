% Use allLFPtab that was created from FOOOF_start_v1

% Go to participant folder then run the directory code 
% EG: Y:\LossAversion\LH_tempSave\allLFPTab_keep\CLASE018

% Save partTab variable in Y:\LossAversion\LH_tempSave\FOOOF_explore\AllEpochsFOOOF

% Load Directory 
mdir = dir; % NWB Dir
dirNames = {mdir.name}; % Names of files in NWB folder
dirFilter = contains(dirNames, 'CLASE'); % Find the files that have 'CLASE' in the name
fileNames = dirNames(dirFilter); % file names

% Initalize table
partTab = table('Size', [0,7], 'VariableTypes',{'string', 'string', 'string', ...
    'string','string','double', 'double'},...
    'VariableNames',{'partID', 'Hemi', 'BrainArea', 'TrialType', 'EpochType','ephysCell', 'powerCell'});

% FOOOF Settings 
f_range = [1,40];
conRange = 1; % change based off of the height of allLFPtab

%% 
for i = 1:length(fileNames)

    % Load temporary file 
    tmpFileName = fileNames{i}; % temp file name 
    load(tmpFileName); % load allLFPtab 

    % Temporary participant ID 
    tmpPartID = strsplit(tmpFileName, '_');
    tmpPartID = string(tmpPartID{1});

    % Temporary brain area 
    tmpBrainArea = string(erase(tmpFileName, '.mat'));
    tmpBrainArea = strsplit(tmpBrainArea, '_');
    tmpBrainArea = tmpBrainArea{3}; % temp brain area

    % Temporary hemisphere
    tmpHemi = strsplit(tmpFileName, '_');
    tmpHemi = string(tmpHemi{2});


    % tmpPartID = 'CLASE018';
    % tmpHemi = 'L';
    % tmpBrainArea = 'AMY';

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

    for si = 1:height(tmpOutGGtab)

        tmpST = tmpOutGGtab.Ephys{si};

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
    TrialType = repmat(string('GG'), tmpLength, 1);
    EpochType = repmat(string('Outcome'), tmpLength, 1);

    tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

    partTab = vertcat(partTab, tmpTAB); % combine tables


    % ---- Outcome - Gamble Loss ---- %
    tmpOutcomeIDX = tmpOut.GambleLoss;
    tmpOutGLtab = tmpOut(tmpOutcomeIDX,:);

    STpsd = []; % holder for start PSD

    for si = 1:height(tmpOutGLtab)

        tmpST = tmpOutGLtab.Ephys{si};

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
    TrialType = repmat(string('GL'), tmpLength, 1);
    EpochType = repmat(string('Outcome'), tmpLength, 1);

    tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

    partTab = vertcat(partTab, tmpTAB); % combine tables


end % for / i

%% 

% Create a column that has the frequency (delta, theta, etc) that is
% associated with the peak frequency from the FOOOF output
freqCell = string.empty;


for i = 1:height(allTab)

    tmpEphys = allTab.ephysCell(i);

    if tmpEphys <= 4 % Delta
        freqCell(i,1) = 'Delta';
    elseif tmpEphys >= 4 && tmpEphys <= 8 % Theta
        freqCell(i,1) = 'Theta';
    elseif tmpEphys >= 8 && tmpEphys <= 12 % Alpha
        freqCell(i,1) = 'Alpha';
    elseif tmpEphys >= 12 && tmpEphys <= 30 % Beta
        freqCell(i,1) = 'Beta';
    else tmpEphys >= 30 % Gamma
        freqCell(i,1) = 'Gamma';
    end % if else


end % for / i


allTab.Frequency = freqCell;