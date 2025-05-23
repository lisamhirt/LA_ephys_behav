function [zscoreEphys] = BandFiltered_Zscore(tempPtID, Freq, cleanVolts)

% Inputs example
% tempPtID = 'CLASE018';
% Freq = [30 200];
% cleanVolts = created from CleanEphys script 

% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer
PCname = getenv('COMPUTERNAME');

switch PCname
    case 'DLPFC' % laptop
        nwbMatCD = 'C:\Users\Lisa\Documents\MATLAB'; % NWB_read path
        synologyCD = 'Z:\LossAversion\Patient folders'; % Synology path
        % NLXEventCD = 'E:\GitKraken\NLX-Event-Viewer\NLX_IO_Code'; % NLX event reader path
    case 'LATERALHABENULA' % lab computer
        nwbMatCD = 'D:\MATLAB';
        synologyCD = 'Y:\LossAversion\Patient folders';
end


%% Delete unneeded variables - from other script
% clearvars -except cleanVolts

%% Load time data from NWB

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

%% Load behavioral file
paths.BehFolder = [strcat(tmpPTpath,'Behavioral-data', '\')];
cd(paths.BehFolder)

behDIR = dir; % behavioral folder DIR
behDIRNames = {behDIR.name}; % Names of files in behavioral folder
behDIRmat = contains(behDIRNames, 'mat'); % Find the files that have ".mat" in the name
tempBehavName = string(behDIRNames(behDIRmat));

eventTab = load(tempBehavName); % load behavioral file

%% Filter cleaned voltages by frequency I want
% Eg: Gamma
% Use the input variable; Freq = [30 200];
% Use the cleaned ephys data, cleanVolts, from CleanEphys script

% Loop through the contacts in cleanVolts and bandpass it

bpVolts = double.empty; % holds bandpass filtered cleaned volts

% JAT question: do I need to envelope the voltages after bandpassing?

for ci = 1:height(cleanVolts)

    tempCon = cleanVolts(ci, :); % temp contact
    tempBP = bandpass(tempCon, Freq, 500);
    [yupper,~] = envelope(tempBP);
    bpVolts(ci,:) = yupper;

end

%% Get Ephys for each epoch

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
    % postTrial = stopTimeBeh+250; % 250 ms after the last event for the trial

    % Equation:
    % sampling rate * number of seconds (x) = number of samples needed 
    % EG: 500 * 0.25 = 125

    % Base line
    baseLineLFP = bpVolts(:, baseLineStart:startTimeBeh); % get out the baseline volt values

    % Get out ephys for each behavioral event / screen seen
    tempOption = bpVolts(:,startTimeBeh:decisionTimeBeh); % time for option screen
    tempDecision = bpVolts(:,decisionTimeBeh:responseTimeBeh); % check to see if this is right. this is more dynamic than not
    tempResponse = bpVolts(:,responseTimeBeh:outcomeTimeBeh); % this is the response time from when they made a response to when the start of the outcome screen is shown
    tempOutcome = bpVolts(:, outcomeTimeBeh:stopTimeBeh); % this one is only 500 ms and not 1000 ms - this is correct

    % tempPost = cleanVolts(:,stopTimeBeh:postTrial);

    % Get out ephys for each behavioral event / screen seen and add -250ms and + 250 ms for each event marker
    % equation to get out seconds before and after the value
    % number to put in = time i want / (1/500)
    % eg: 2 seconds / (1/500) = 250
    % put 250 instead of 500 to get 2 seconds
    % tempOptionPP = bpVolts(:,(startTimeBeh-250):(decisionTimeBeh+250));
    % tempDecisionPP = bpVolts(:,(decisionTimeBeh-250):(responseTimeBeh+250));
    % tempResponsePP = bpVolts(:,(responseTimeBeh-250):(outcomeTimeBeh+250));
    % tempOutcomePP =  bpVolts(:, (outcomeTimeBeh-250):(stopTimeBeh+250));

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

%% Z Score data
% Use the pre ephys to zscore the epoch

zscoreEphys = cell.empty; % Hold all of the bandpass and zscored ephys
zscoreEphys(:,1) = allLFP(:,1); % copy the epoch screen numbers to the first column

% Replace TTL numbers with Epoch names
idx60 = cellfun(@(x) isequal(x, 60), zscoreEphys); % Find indices of 60
zscoreEphys(idx60) = {'Start'}; % Replace 60 with 'Start'

idx64 = cellfun(@(x) isequal(x, 64), zscoreEphys); % Find indices of 64
zscoreEphys(idx64) = {'Decision'}; % Replace 64 with 'Decision'

idx62 = cellfun(@(x) isequal(x, 62), zscoreEphys); % Find indices of 62
zscoreEphys(idx62) = {'Response'}; % Replace 62 with 'Response'

idx70 = cellfun(@(x) isequal(x, 70), zscoreEphys); % Find indices of 70
zscoreEphys(idx70) = {'Outcome'}; % Replace 70 with 'Outcome'

for zi = 1:length(allLFP)

    tempPre = allPre{zi,2}; % temp pre for first epoch, all contacts
    tempEpoch = allLFP{zi,2}; % temp epoch

    % JAT do i need to do it by contact or can i average them?
    tempEpochCell = zeros(size(tempEpoch)); % overright cell everytime

    for zz = 1:height(tempPre)

        tempPreCon = tempPre(zz, :);
        tempMean = mean(tempPreCon);
        tempSTD = std(tempPreCon);

        % tempEpochCon = tempEpoch(zz,:);

        % for zc = 1:length(tempEpochCon)

            tempZscore = (tempEpoch(zz,:) - tempMean) / tempSTD; % compute z score
            tempEpochCell(zz,:) = tempZscore;

        % end % for / zc

    end % for / zz

    zscoreEphys(zi,2) = {tempEpochCell}; % put z score ephys into the epoch row

end % for / zi


end % function