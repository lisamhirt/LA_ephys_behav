PCname = getenv('COMPUTERNAME');

switch PCname
    case 'DLPFC' % laptop
        synologyCD = 'Z:\LossAversion\Patient folders'; % Synology path
    case 'LATERALHABENULA' % lab computer
        synologyCD = 'Y:\LossAversion\Patient folders';
        ephysCD = 'Y:\LossAversion\LH_tempSave'; % Ephys path
end


%% Load behavioral file

% Navigate to CLASE subject repository
% tempPtID = 'CLASE018'; % Patient ID
tempPtID = 'CLASE018';

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

% Gain/loss trials - this measures loss aversion
LA_trials = eventTab.subjdata.cs.riskyLoss < 0 & ~checkIndex;
% Gain only trials - this measures risk aversion
RA_trials = eventTab.subjdata.cs.riskyLoss == 0 & ~checkIndex;

% Gamble
gamble_trials = eventTab.subjdata.cs.choice == 1 & ~checkIndex;
% Alternative
alternative_trials = eventTab.subjdata.cs.choice == 0 & ~checkIndex;
% Outcome Loss
outcomeLoss = eventTab.subjdata.cs.outcome < 0 & ~checkIndex;
% Outcome no change
outcomeNeutral = eventTab.subjdata.cs.outcome == 0 & ~checkIndex;
% Outcome gain
outcomeGain = eventTab.subjdata.cs.outcome > 0 & ~checkIndex;

% Reaction Times 
reactionTimes = eventTab.subjdata.cs.RTs;

%% Histogram
histogram(reactionTimes)

%% Line plot 
plot(reactionTimes)

%% Pull out LA / Alt trials 
LA_Gamble = all(LA_trials & gamble_trials, 2);

LA_Alt = all(LA_trials & alternative_trials,2); % LA and alternative

% Get reaction times 
LA_gamble_RT = reactionTimes(LA_Gamble);
LA_alt_RT = reactionTimes(LA_Alt);
%%
figure;
histogram(LA_gamble_RT)
%%
histogram(LA_alt_RT)
%%
[~, pval] = kstest2(LA_gamble_RT, LA_gamble_RT);