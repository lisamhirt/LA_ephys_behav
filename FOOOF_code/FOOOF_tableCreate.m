
mainDIR = 'Z:\LossAversion\LH_tempSave\FOOOF_explore';
cd(mainDIR);

mdir = dir;
fdir = {mdir.name};
dirPTnames = fdir(contains(fdir,'CLASE')); % List of part folder names

for i = 1:length(dirPTnames)

    tmpPartID = dirPTnames{i}; % temp participant name
    cd(strcat(mainDIR, '\' ,tmpPartID, '\')); % CD into temp part folder

    % Temp participant directory
    ptDIR = dir;
    ptDIR2 = {ptDIR.name};
    ptDIRnames = ptDIR2(contains(ptDIR2,'.mat')); % list of files in part folder

    ephysCell = [];

    for pi = 1:length(ptDIRnames)

        tmpFileName = ptDIRnames{pi}; % temp file name
        tmpFile = load(tmpFileName); % load temp file

        tmpFN = fieldnames(tmpFile); % temp field names
        tmpFN2 = tmpFN{1}; % get FN out of the cell format

        % Peak Params
        peakParams = tmpFile.(tmpFN2).peak_params;
        peakParams = peakParams(:,1); % Peak central frequency

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
        tmpTrialtype2 = string(tmpTrialtype2);

        tmpPartID = string(tmpPartID);

        ephysCell = [ephysCell; peakParams];

    end % for / pi

    tmpLength = length(ephysCell);

    partID = repmat(tmpPartID,tmpLength,1);
    Hemi = repmat(tmpHemi, tmpLength,1);
    BrainArea = repmat(tmpBrainArea2, tmpLength, 1);

    partTab = table(partID, Hemi, BrainArea, ephysCell);
    % stopped  here. Have one table done but need to figure out how to add
    % more participants to it


end % for / i