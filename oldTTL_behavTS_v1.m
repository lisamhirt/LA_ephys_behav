% Old TTL BehavTimeStamps 

%% 1. Artifact reject and bipolar refrence electrodes of interest 

% [cleanVolts] = CleanEphys_v2(tempPtID, shortBA, std_thresh, numCon);
[cleanVolts] = CleanEphys_v2('CLASE007', 'LAMY', 6, 1:2);


%% Load time data from NWB

% Navigate to CLASE subject repository
% tempPtID = 'CLASE007'; % Patient ID

tmpPTpath = strcat(synologyCD,'\', tempPtID,'\'); % Patient path on synology

paths = [];
paths.NWBdata = [strcat(tmpPTpath, 'NWB-processing','\', 'NWB_Data', '\')]; % Path to PtID NWB data
cd(paths.NWBdata) % CD to pt NWB data

nwbdir = dir; % NWB Dir
nwbdirNames = {nwbdir.name}; % Names of files in NWB folder
nwbdirFilter = contains(nwbdirNames, 'filter'); % Find the NWB files that have 'Filter' in the name
tempLAname = string(nwbdirNames(nwbdirFilter)); % String the NWB file that has 'filter' in it

tmp_LA = nwbRead(tempLAname); % Load the filter NWB file

% Load in timestamps
ma_timestamps = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').timestamps.load;

% Downsample timedata
ma_timestampsDS = downsample(ma_timestamps, 8); % this is downstampled by a factor of 8

% Get behavioral timestamp data %
% These are in microseconds
eventStamps = tmp_LA.acquisition.get('events').timestamps.load; % probably don't need this anymore
% eventIDs = tmp_LA.acquisition.get('events').data.load; % This doesn't
% work anymore bc TTLs are different 


%% Load behavioral file 

% CD to participant folder 
cd('Y:\LossAversion\Patient folders\CLASE007\Behavioral-data\EventBehavior');

% Load behavior table with time markers on it 
tmpTab = load("clase007_BehEvTable_v2.mat");

%% Testing 
% Get the first TS in the beahv tab 
testTempTS = tmpTab.eventTABLE.TrialEvTm(1);
% Temp off seconds for first row 
testTempOff = tmpTab.eventTABLE.OffsetSecs(1);
% Temp time to look for 
testTempTime = testTempTS - testTempOff;
testTempTimeMIN = min(testTempTime);


% Taken from other code 
% [~, startTimeBeh] = min(abs(startTime - ma_timestampsDS));
[ROWSfind, COLfind] = min(abs(testTempTS - testTempOff));




