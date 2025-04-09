
mainDIR = 'Z:\LossAversion\LH_tempSave\FOOOF_explore';
cd(mainDIR);

mdir = dir;
fdir = {mdir.name};
dirPTnames = fdir(contains(fdir,'CLASE')); % List of part folder names

% Initalize table
partTab = table('Size', [0,7], 'VariableTypes',{'string', 'string', 'string', ...
    'string','string','double', 'double'},...
    'VariableNames',{'partID', 'Hemi', 'BrainArea', 'TrialType', 'EpochType','ephysCell', 'powerCell'});
%%
for i = 1:length(dirPTnames)

    tmpPartID = dirPTnames{i}; % temp participant name
    cd(strcat(mainDIR, '\' ,tmpPartID, '\')); % CD into temp part folder

    % Temp participant directory
    ptDIR = dir;
    ptDIR2 = {ptDIR.name};
    ptDIRnames = ptDIR2(contains(ptDIR2,'.mat')); % list of files in part folder


    for pi = 1:length(ptDIRnames)

        tmpFileName = ptDIRnames{pi}; % temp file name
        tmpFile = load(tmpFileName); % load temp file

        tmpFN = fieldnames(tmpFile); % temp field names
        tmpFN2 = tmpFN{1}; % get FN out of the cell format

        ephysCell = [];
        powerCell = [];


        for pii = 1:width(tmpFile.((tmpFN2)))

            % Peak Params
            peakParams = tmpFile.(tmpFN2);
            peakParams2 = peakParams(pii).peak_params;
            peakParams3 = peakParams2(:,1);

            % Add to cell
            ephysCell = [ephysCell; peakParams3];

            % Power Params 
            powerParams = tmpFile.(tmpFN2);
            powerParams2 = powerParams(pii).peak_params;
            powerParams3 = powerParams2(:,2);

            % Add to cell 
            powerCell = [powerCell; powerParams3];

        end % for / pii


        % Temporary brain area name
        tmpBrainArea = strsplit(tmpFileName, '_');
        tmpBrainArea = tmpBrainArea{2}; % temp brain area (with hemi)

        % Temporary hemisphere
        tmpHemi = tmpBrainArea(1);
        tmpHemi = string(tmpHemi);
        % Temp Brain area
        tmpBrainArea2 = extractAfter(tmpBrainArea, tmpHemi);
        tmpBrainArea2 = string(tmpBrainArea2);

        % Temporary trial type
        % Remove the file extension
        filenameNoExt = erase(tmpFileName, '.mat');
        tmpTrialtype = strsplit(filenameNoExt, '_');
        tmpTrialtype = tmpTrialtype{3};
        tmpTrialtype2 = extractAfter(tmpTrialtype, 'outcome'); % Trial Type
        tmpTrialtype3 = string(tmpTrialtype2);

        % Temporary epoch
        tmpEpochtype = extractBefore(tmpTrialtype,tmpTrialtype3);
        tmpEpochtype2 = string(tmpEpochtype);

        % String part ID
        tmpPartID = string(tmpPartID);

        tmpLength = length(ephysCell);

        partID = repmat(tmpPartID,tmpLength,1);
        Hemi = repmat(tmpHemi, tmpLength,1);
        BrainArea = repmat(tmpBrainArea2, tmpLength, 1);
        TrialType = repmat(tmpTrialtype3, tmpLength, 1);
        EpochType = repmat(tmpEpochtype2, tmpLength, 1);


        tmpTAB = table(partID, Hemi, BrainArea, TrialType, EpochType, ephysCell, powerCell);

        partTab = vertcat(partTab, tmpTAB); % combine tables

    end % for / pi



end % for / i

%%
writetable(partTab, 'FOOOF_explore_power.csv');