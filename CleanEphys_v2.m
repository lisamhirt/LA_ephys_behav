function [cleanVolts] = CleanEphys_v2(tempPtID, shortBA, std_thresh, numCon)

% Inputs example 
% tempPtID = 'CLASE018';
% shortBA = 'LAMY';
% std_thresh = 6;

% Number of contacts in brain area (EG: (1:3))
% numCon = 1:3;

% Outputs 
% cleanVolts: cleaned ephys data that has been artifact rejected and bipolar refrenced. 
% Per brain area and contacts within the brain area 

% The Bipolar refrencing on this function keeps all the contacts and
% doesn't get rid of one 

%% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer 
PCname = getenv('COMPUTERNAME');

switch PCname
    case 'DLPFC' % laptop
        nwbMatCD = 'C:\Users\Lisa\Documents\MATLAB'; % NWB_read path 
        synologyCD = 'Z:\LossAversion\Patient folders'; % Synology path 
        NLXEventCD = 'E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'; % NLX event reader path 
        addpath('E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'); % add NLX files to path 
        addpath(genpath([strcat(nwbMatCD,'\matnwb-2.5.0.0')])); % add nwb_read and subfolders to path
    case 'LATERALHABENULA' % lab computer
        nwbMatCD = 'C:\Users\Lisa\Documents\MATLAB';
        synologyCD = 'Y:\LossAversion\Patient folders'; % Synology path 
        NLXEventCD = 'Z:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'; % NLX event reader path
        addpath('Z:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'); % add NLX files to path 
        addpath(genpath([strcat(nwbMatCD,'\matnwb-2.5.0.0')])); % add nwb_read and subfolders to path
end

% Add NWB reader and NLX files to path  
% addpath(genpath([strcat(nwbMatCD,'\matnwb-2.5.0.0')])); % add nwb_read and subfolders to path
% addpath('E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'); % add NLX files to path 

%% Load patient NWB file

% Navigate to CLASE subject repository 
% tempPtID = 'CLASE018'; % Patient ID 
tmpPTpath = strcat(synologyCD,'\', tempPtID,'\'); % Patient path on synology

paths = [];
paths.NWBdata = [strcat(tmpPTpath, 'NWB-processing','\', 'NWB_Data', '\')]; % Path to PtID NWB data
cd(paths.NWBdata) % CD to pt NWB data 

nwbdir = dir; % NWB Dir 
nwbdirNames = {nwbdir.name}; % Names of files in NWB folder
nwbdirFilter = contains(nwbdirNames, 'filter'); % Find the NWB files that have 'Filter' in the name 
tempLAname = string(nwbdirNames(nwbdirFilter)); % String the NWB file that has 'filter' in it

tmp_LA = nwbRead(tempLAname); % Load the filter NWB file

% Voltage data for all macrowires and their channels 
ma_data = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').data.load;

% % Load in timestamps 
% ma_timestamps = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
%     ('LFP').electricalseries.get('MacroWireSeries').timestamps.load;
% 
% % Downsample timedata
% ma_timestampsDS = downsample(ma_timestamps, 8); % this is downstampled by a factor of 8



%% Brain area data 
% Get brain area names from NWB data 
shortBAname = tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('shortBAn').data.load; % short brain area name 
% longBAname = tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('location').data.load; % long brain area name 

% Electrode names for only MA 
electrodeType = tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('label').data.load; % filter for MA and get rid of MI (microwire)
electrodeTypeMA = cellstr(electrodeType);
elecMIflag = contains(electrodeTypeMA, 'MI');
electrodeTypeMA(elecMIflag == 1) = []; % now only has MA 

% Shorten BA names %
% Short names 
shortBAnameMA = cellstr(shortBAname);
shortBAnameMA(elecMIflag == 1) =[];

% Get brain area locations
baFlag = contains(shortBAnameMA, shortBA);

% Get voltage for brain area locations 
baVoltRaw = ma_data(baFlag, :);


%% Artifact Rejection %%

% Inputs for artifact Rejection are standard deviation threshold and the
% number of contacts of interest 
% std_thresh = 6;
% numCon = 1:3;

% Get contacts from electrode you want
tempVolt = baVoltRaw(numCon, :);

for i = 1:length(numCon)

    % Get 1 contact at a time
    tempCon = double(tempVolt(i, :));

    % Create threshold variable
    mLFP = mean(tempCon);
    sLFP = std(tempCon);
    tempThresh = mLFP+(sLFP*std_thresh); % threshold

    threshLoc = double.empty; % will hold the locations of all the volts that went over threshold

    % for j = 1:length(tempCon)
        threshLoc = abs(tempCon) > tempThresh;
    % end % for / j / length(tempCon)

    % Sum threshloc to see if there are over 4% of volts that went above the
    % threshold

    sumThresh = sum(threshLoc);
    perOverThresh = sumThresh/length(tempCon); % it's less than 4 percent!

    % Replace the row with NaN if it is over 4 %
   
    if perOverThresh > 0.04
        tempVolt(i,:) = nan;

    end % if else

    % artVolt has all of the voltages per contact that passed the artifact
    % rejection


end % for / length(numCon)

    [artVolt] = tempVolt; 

% End of artifact rejection 

%% Bipolar Refrencing %%

baVoltBI = zeros(height(artVolt), width(artVolt)); % this now has the bipolar refrenced voltages for the brain area of interest

for bi = 1: height(artVolt)

    if bi ~= height(artVolt)

        tempChanInt = artVolt(bi,:); % channel of interst
        tempChanOth = artVolt((bi+1), :); % channel below that will be averaged with channel of interest

        tempVoltRef =  tempChanOth - tempChanInt;
        baVoltBI(bi,:) = tempVoltRef;

    else bi == height(artVolt)

        tempChanInt = artVolt(bi,:); % channel of interst
        tempChanOth = artVolt(1, :); % channel below that will be averaged with channel of interest

        tempVoltRef =  tempChanOth - tempChanInt;
        baVoltBI(bi,:) = tempVoltRef;

    end % if else

end % for bi

cleanVolts = baVoltBI;

end % function