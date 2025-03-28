%% ---- 1. Clean ephys data ---- %%
% Pull in ephys from brain area, artifact reject it and bipolar refrence it
% Use code name CleanEphys_v2 

% [cleanVolts] = CleanEphys_v2(tempPtID, shortBA, std_thresh, numCon);
[cleanVolts] = CleanEphys_v2('CLASE018', 'RAH', 6, 3:5);

% Inputs example 
% tempPtID = 'CLASE018';
% shortBA = 'LAMY';
% std_thresh = 6;
% Number of contacts of interest (1:3)
% numCon = 1:3;

% Outputs 
% cleanVolts: cleaned ephys data, per contact, that has been artifact 
% rejected and bipolar refrenced. 
% Per brain area and contacts within the brain area 

%% ---- 2. Create epochs for ephys ---- %%

% Inputs
% cleanVolts from above code 
tempPtID = 'CLASE018';

% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer
PCname = getenv('COMPUTERNAME');

switch PCname
    case 'DLPFC' % laptop
        nwbMatCD = 'C:\Users\Lisa\Documents\MATLAB'; % NWB_read path
        synologyCD = 'Z:\LossAversion\Patient folders'; % Synology path
        ephysCD = 'Z:\LossAversion\LH_tempSave';
        % NLXEventCD = 'E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'; % NLX event reader path
    case 'LATERALHABENULA' % lab computer
        nwbMatCD = 'D:\MATLAB';
        synologyCD = 'Y:\LossAversion\Patient folders';
        ephysCD = 'Y:\LossAversion\LH_tempSave'; % Ephys path
end

% Load time data from NWB %

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

% Load in timestamps
ma_timestamps = tmp_LA.processing.get('ecephys').nwbdatainterface.get...
    ('LFP').electricalseries.get('MacroWireSeries').timestamps.load;

% Downsample timedata
ma_timestampsDS = downsample(ma_timestamps, 8); % this is downstampled by a factor of 8

% Get behavioral timestamp data %
% These are in microseconds
eventStamps = tmp_LA.acquisition.get('events').timestamps.load;
eventIDs = tmp_LA.acquisition.get('events').data.load;

% Load behavioral file 
paths.BehFolder = [strcat(tmpPTpath,'Behavioral-data', '\')];
cd(paths.BehFolder)

behDIR = dir; % behavioral folder DIR
behDIRNames = {behDIR.name}; % Names of files in behavioral folder
behDIRmat = contains(behDIRNames, 'mat'); % Find the files that have ".mat" in the name
tempBehavName = string(behDIRNames(behDIRmat));

eventTab = load(tempBehavName); % load behavioral file


% Get Ephys for each epoch %

% Create Event ID's From Behavioral TTLs %

eventIDs = cellstr(eventIDs); % make eventIDs a cell instead of a string
hexFlagsTTL = contains(eventIDs,'TTL Input'); % keeps this now a logical vector

behvFlagsTTL = hexFlagsTTL;
importNum = [60 62 64 70 74]; % behavioral TTL IDs
behvFlagID = []; % this will hold all of the behavioral event markers from the TTLs in order
behvIDcount = 1; % counter

for hi = 1: length(hexFlagsTTL)
    if hexFlagsTTL(hi)
        tmpRow = eventIDs{hi};
        hexOnly = extractBetween(tmpRow,'(',')');
        decFhex = hex2dec(hexOnly);
        tempMem = ismember(decFhex, importNum);
        behvFlagsTTL(hi) = tempMem;

        if tempMem
            behvFlagID(behvIDcount) = decFhex;
            behvIDcount = behvIDcount + 1;
        end

    end % if hexFlagsTTL
end % for

% Separate ephys data based on behavioral event IDs %

% behvFlagsTTL are the TTL stamps where you care about
behvFlagID = behvFlagID';
behvEventStamps = eventStamps(behvFlagsTTL); % pulled out the timestamps for events i care about

% Behavioral event IDs
startID = [60]; % this is the first screen they see that shows them their options and before they choose
decisionID = [64]; % decision screen ID
reponseID = [62]; % participant response
outcomeID = [70]; % outcome screen
endID = [74]; % outcome screen goes away

% Vector that reapeats itself 135 times but will be a placeholder for the 5
% event markers in each trial
trialNumVec = reshape(repmat(1:135, 5,1), 675,1);

% Vector that holds all the behavoral event ephys data
allLFP = double.empty;
allLFP(:,1) = behvFlagID;
allLFP = num2cell(allLFP);

% Create an empty vector to hold all the pre/post ephys data per behavioral
% event. First column is the behavioral event ID, second is the pre for the
% whole trial, and the third column is the post for the whole trial. The second
% third columns are repeated for each behavior marker / event ID per trial
allPre = double.empty;
allPre(:,1) = behvFlagID;
allPre = num2cell(allPre);


for li = 1:135

    % Get out time stamps for each behavioral marker
    trialLog = ismember(trialNumVec, li); % Get trial
    startTime = behvEventStamps(trialLog & behvFlagID == startID);
    decisionTime = behvEventStamps(trialLog & behvFlagID == decisionID);
    responseTime = behvEventStamps(trialLog & behvFlagID == reponseID);
    outcomeTime = behvEventStamps(trialLog & behvFlagID == outcomeID);
    stopTime = behvEventStamps(trialLog & behvFlagID == endID);

    % Get out the location of those time stamps for the behavior marker
    [~, startTimeBeh] = min(abs(startTime - ma_timestampsDS));
    [~, decisionTimeBeh] = min(abs(decisionTime - ma_timestampsDS));
    [~, responseTimeBeh] = min(abs(responseTime - ma_timestampsDS));
    [~, outcomeTimeBeh] = min(abs(outcomeTime - ma_timestampsDS));
    [~, stopTimeBeh] = min(abs(stopTime - ma_timestampsDS));

    % Set up baseline / pre / -250 ms before each trial
    baseLineStart = startTimeBeh-125; % 250 ms before the start of the first event

    % Equation:
    % sampling rate * number of seconds (x) = number of samples needed 
    % EG: 500 * 0.25 = 125

    % Base line
    bpVolts = cleanVolts; % copy volts 
    baseLineLFP = bpVolts(:, baseLineStart:startTimeBeh); % get out the baseline volt values

    % Get out ephys for each behavioral event / screen seen
    tempOption = bpVolts(:,startTimeBeh:decisionTimeBeh); % time for option screen
    tempDecision = bpVolts(:,decisionTimeBeh:responseTimeBeh); % check to see if this is right. this is more dynamic than not
    tempResponse = bpVolts(:,responseTimeBeh:outcomeTimeBeh); % this is the response time from when they made a response to when the start of the outcome screen is shown
    tempOutcome = bpVolts(:, outcomeTimeBeh:stopTimeBeh); % this one is only 500 ms and not 1000 ms - this is correct

    % Find location for each event marker and save in cell
    startLoc = find(trialLog & behvFlagID == startID);
    allLFP{startLoc, 2} = tempOption;
    % allLFP{startLoc, 3} = tempOptionPP; % +/- 500 ms around marker

    decisLoc = find(trialLog & behvFlagID == decisionID);
    allLFP{decisLoc, 2} = tempDecision;
    % allLFP{decisLoc, 3} = tempDecisionPP;

    responseLoc = find(trialLog & behvFlagID == reponseID);
    allLFP{responseLoc, 2} = tempResponse;
    % allLFP{responseLoc, 3} = tempResponsePP;

    outcomeLoc = find(trialLog & behvFlagID == outcomeID);
    allLFP{outcomeLoc, 2} = tempOutcome;
    % allLFP{outcomeLoc, 3} = tempOutcomePP;

    % Save pre and post for trail in a different cell
    repeatloc = find(trialLog == 1);

    % Pre / baseline repeat
    allPre(repeatloc,2) = repelem({baseLineLFP}, length(repeatloc));

end % for / li

% Remove every row that has '74' in it
allLFP(cellfun(@(x) isequal(x, 74), allLFP(:,1)), :) = [];
allPre(cellfun(@(x) isequal(x, 74), allPre(:,1)), :) = [];

% Replace TTL numbers with Epoch names
idx60 = cellfun(@(x) isequal(x, 60), allLFP); % Find indices of 60
allLFP(idx60) = {'Start'}; % Replace 60 with 'Start'

idx64 = cellfun(@(x) isequal(x, 64), allLFP); % Find indices of 64
allLFP(idx64) = {'Decision'}; % Replace 64 with 'Decision'

idx62 = cellfun(@(x) isequal(x, 62), allLFP); % Find indices of 62
allLFP(idx62) = {'Response'}; % Replace 62 with 'Response'

idx70 = cellfun(@(x) isequal(x, 70), allLFP); % Find indices of 70
allLFP(idx70) = {'Outcome'}; % Replace 70 with 'Outcome'

%% ---- 3. Separate ephys per epochs and gambling / alternative ---- % 

% Use the script gambleEpochEphys_v1 

% Input examples

% tempPtID = 'CLASE018';
% trialType = 'LA';
% gambleType = {'gamble', 'alt'};
% outcomeType = {'loss', 'noChange', 'gain'};
% epochINT = {'Start', 'Decision', 'Response', 'Outcome'};


% [allLFPtab epochEphys] = gambleEpochEphys_v1(allLFP, tempPtID, trialType, gambleType, outcomeType, epochINT);

[allLFPtab epochEphys] = gambleEpochEphys_v1(allLFP, 'CLASE018', 'LA', {'gamble', 'alt'}, {'loss', 'noChange', 'gain'}, {'Start', 'Decision', 'Response', 'Outcome'});


%% ephys to keep 

clearvars -except allLFPtab epochEphys;

%%

allLFPtab is the cleaned ephys for each epoch. 
epochEphys is cleaned ephys for each epoch but has been processed more and found the minimum ephys responses per condition 
