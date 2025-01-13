
% Clean ephys and select brain area 

% Outputs:
% Matrix of bipolar referenced contacts from a single wire
% Inputs: 
% Subject ID, NWB file ID, Brain region name (either short or long)

% Navigate to CLASE subject repository 
% Match CLASE subject folder ID with input argument for Subject ID
% Navigate to NWB folder in subject folder
% Load NWB that matches input argument for NWB file ID
% Use NWB Channel names to find channel indices that match input argument for Brain region name
% Extract sub index for brain region from raw LFP data matrix
% Conduct contact by contact artifact rejection 
% Conduct bipolar referencing on remaining channels
% OUTPUT matrix of bipolar referenced channels for specified wire

% tempPtID = 'CLASE018';
% shortBA = 'LAMY';
% std_thresh = 2;


%% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer 
PCname = getenv('COMPUTERNAME');

switch PCname
    case 'DLPFC' % laptop
        nwbMatCD = 'C:\Users\Lisa\Documents\MATLAB'; % NWB_read path 
        synologyCD = 'Z:\LossAversion\Patient folders'; % Synology path 
        NLXEventCD = 'E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'; % NLX event reader path 
    case 'DESKTOP-3MTJ3ND' % lab computer
        nwbMatCD = 'D:\MATLAB';
end

% Add NWB reader and NLX files to path  
addpath(genpath([strcat(nwbMatCD,'\matnwb-2.5.0.0')])); % add nwb_read and subfolders to path
addpath('E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'); % add NLX files to path 

%%
% Navigate to CLASE subject repository 

tempPtID = 'CLASE018'; % Patient ID 
tmpPTpath = strcat(synologyCD,'\', tempPtID,'\'); % Patient path on synology

paths = [];
paths.NWBdata = [strcat(tmpPTpath, 'NWB-processing','\', 'NWB_Data', '\')]; % Path to PtID NWB data
cd(paths.NWBdata) % CD to pt NWB data 

nwbdir = dir; % NWB Dir 
nwbdirNames = {nwbdir.name}; % Names of files in NWB folder
nwbdirFilter = contains(nwbdirNames, 'filter'); % Find the NWB files that have 'Filter' in the name 
tempLAname = string(nwbdirNames(nwbdirFilter)); % String the NWB file that has 'filter' in it

tmp_LA = nwbRead(tempLAname); % Load the filter NWB file

%% ephys timestamps data are in microseconds
% mi_timestamps = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
%     ('LFP').electricalseries.get('MicroWireSeries').timestamps.load; %
%    this is for micro 

% Loads in Macrowire timestamps 
ma_timestamps = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').timestamps.load;

% Voltage data for all macrowires and their channels 
ma_data = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').data.load;

% To get sampling frequency info you get it from the description 
% ma_sampFreq = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
%     ('LFP').electricalseries.get('MacroWireSeries');

% the sampling rate for the filtered data is downsampled to 500 Hz. My sampling freq is 500 Hz. 
% use this to create power spectral denisty plots 

%% Brain area data 
% Get brain area names from NWB data 
shortBAname = tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('shortBAn').data.load; % short brain area name 
longBAname = tmp_LA.general_extracellular_ephys_electrodes.vectordata.get('location').data.load; % long brain area name 

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

%% Ephys and brain area of interest 

% Get voltage for brain area locations 
baVoltRaw = ma_data(baFlag, :);

% Artifact Rejection %

% Inputs for artifact Rejection 
% std_thresh = 2;










%% behavioral timestamps data are in microseconds
eventStamps = tmp_LA.acquisition.get('events').timestamps.load;
eventIDs = tmp_LA.acquisition.get('events').data.load;

%%