function [allLFPtab epochEphys] = gambleEpochEphys_v1(allLFP, tempPtID, trialType, gambleType,outcomeType, epochINT)

% Inputs example %
% tempPtID = 'CLASE026';
% trialType = 'LA'; or 'RA'
% trialType = 'LA';
% gambleType = {'gamble', 'alt'};
% gambleType = {'gamble'};
% gambleType = {'alt'};

% Define outcomeType as a cell array of strings
% outcomeType = {'loss', 'noChange', 'gain'};
% outcomeType = {'gain'};

% epochINT = {'Start', 'Decision', 'Response', 'Outcome'};

% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer

%% Load behavioral file

% Navigate to CLASE subject repository
% tempPtID = 'CLASE018'; % Patient ID

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

tmpPTpath = strcat(synologyCD,'\', tempPtID,'\'); % Patient path on synology
paths.BehFolder = [strcat(tmpPTpath,'Behavioral-data', '\')];
cd(paths.BehFolder)

behDIR = dir; % behavioral folder DIR
behDIRNames = {behDIR.name}; % Names of files in behavioral folder
behDIRmat = contains(behDIRNames, 'mat'); % Find the files that have ".mat" in the name
tempBehavName = string(behDIRNames(behDIRmat));

eventTab = load(tempBehavName); % load behavioral file

%% Behavior %%

% Trial type info
% Check trial
checkIndex = eventTab.subjdata.cs.ischecktrial;

% riskyloss < 0 = gain/loss trial :: either gain X or lose Y
% riskyloss == 0 = gain only :: either gain X or lose 0
% choice 1 = gamble, 0 = alternative

% Loss aversion (LA) or risk aversion (RA)
if strcmpi('LA', trialType) == 1
    % Gain/loss trials - this measures loss aversion
    LA_trials = eventTab.subjdata.cs.riskyLoss < 0 & ~checkIndex;
else
    % Gain only trials - this measures risk aversion
    RA_trials = eventTab.subjdata.cs.riskyLoss == 0 & ~checkIndex;
end % if else for trialType

% Gamble type (gamble or alternative)
for gi = 1:length(gambleType)
    if strcmpi('gamble', gambleType{gi})
        gamble_trials = eventTab.subjdata.cs.choice == 1 & ~checkIndex;
    else strcmpi('alt', gambleType{gi})
        alternative_trials = eventTab.subjdata.cs.choice == 0 & ~checkIndex;
    end % if else - gamble type
end % for - gamble type



% Outcome results
% Loop through each outcome type
for oi = 1:length(outcomeType)
    if strcmpi('loss', outcomeType{oi})
        outcomeLoss = eventTab.subjdata.cs.outcome < 0 & ~checkIndex;
    elseif strcmpi('noChange', outcomeType{oi})
        outcomeNeutral = eventTab.subjdata.cs.outcome == 0 & ~checkIndex;
    elseif strcmpi('gain', outcomeType{oi})
        outcomeGain = eventTab.subjdata.cs.outcome > 0 & ~checkIndex;
    else
        disp(['Invalid outcomeType: ', outcomeType{oi}]);
    end % if elsed
end % for


%%
% Gamble type / if they gamble or took the alternative %

for gii = 1:length(gambleType)
    if strcmpi('gamble', gambleType{gii})
        LA_Gamble = all(LA_trials & gamble_trials, 2); % LA and when they gambled

        % Create column that has gamble and LA trials repeated
        LA_Gamble_rep = num2cell(reshape(repmat(LA_Gamble', 4, 1), [], 1));

        for oii = 1:length(outcomeType)

            if strcmpi('loss', outcomeType{oii})
                LA_GL = all(LA_Gamble & outcomeLoss, 2);

                % Create column that has if was LA_GL repeated
                LA_GL_rep = num2cell(reshape(repmat(LA_GL', 4, 1), [], 1));

            elseif strcmpi('noChange', outcomeType{oii})
                continue

            else strcmpi('gain', outcomeType{oii})
                LA_GG = all(LA_Gamble & outcomeGain, 2);

                % Create column that has if it was LA_GG repeated
                LA_GG_rep = num2cell(reshape(repmat(LA_GG', 4, 1), [], 1));

            end % if else
        end % for / oii

    else strcmpi('alt', gambleType{gii}) % alternative
        LA_Alt = all(LA_trials & alternative_trials,2); % LA and alternative

        % Create column that has LA and Alternative trials repeated 
        LA_Alt_rep = num2cell(reshape(repmat(LA_Alt', 4, 1), [], 1));

        % Outcome no change
        LA_AN = all(LA_Alt & outcomeNeutral, 2); % LA, alternative, and no change outcome

        % Create column that has if was LA_GL repeated
        % LA_AN_rep = num2cell(reshape(repmat(LA_AN', 4, 1), [], 1));

    end % if else / gamble or alternative
end % for / gii / gamble type

% Create tables for each variable
tmpCell = [LA_Gamble_rep, LA_Alt_rep, LA_GL_rep, LA_GG_rep];
tmpBehavTab = cell2table(tmpCell, "VariableNames",["Gamble" "Alternative" "GambleLoss" "GambleGain"]);


% Ephys %

% Convert allLFP cell to table 
allLFPtab = cell2table(allLFP,"VariableNames",["EpochID" "Ephys"]);

% add tmpBehavTab to allLFPtab 
allLFPtab = [allLFPtab, tmpBehavTab];

% Use innerSwarm_v3 code to create behavor and ephys table 
epochEphys = innerSwarm_v3(allLFPtab, epochINT);

end % function 