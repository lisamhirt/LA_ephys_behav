%% Get behavior / gambling info 
cd('Y:\LossAversion\Patient folders\CLASE018\Behavioral-data'); % CD to patient folder

% Load behavior file 
eventTab = load("clase_behavior_CLASE018_738812.7161.mat");

% Check trial
checkIndex = eventTab.subjdata.cs.ischecktrial;

% riskyloss < 0 = gain/loss trial :: either gain X or lose Y
% riskyloss == 0 = gain only :: either gain X or lose 0
% choice 1 = gamble, 0 = alternative

% Gain/loss trials - this measures loss aversion
gainLOSS_trials = eventTab.subjdata.cs.riskyLoss < 0 & ~checkIndex;
% Gain only trials - thsi measures risk aversion
gainONLY_trials = eventTab.subjdata.cs.riskyLoss == 0 & ~checkIndex;

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

% Get the money values 
moneyTrial = eventTab.subjdata.cs.outcome; 

%%
% copy variables
gainLossTrials = gainLOSS_trials;
gambleTrials = gamble_trials; 
outcomeLossTrial = outcomeLoss; 
outcomeGainTrial = outcomeGain; 

%% find what trials they gambled on, then if they won or loss 
% start with gain loss trials since i only care about those and see what
% gain loss trials they decided to gamble on 
gainLoss_gambled = find(all(gainLossTrials & gambleTrials, 2)); % gives me the rows that they gambled on a gain loss trial 

% see if they won (gained) on their gamble. 1 means yes they gained 0 means no 
gainLoss_gamble_outcomeGain= outcomeGainTrial(gainLoss_gambled); 

% see if they loss on their gamble 
gainLoss_gamble_outcomeLoss = outcomeLossTrial(gainLoss_gambled); 

%% Ephys 

% CD to folder 
cd('Y:\LossAversion\LH_tempSave\CLASE018\Left');

% Load ephys per brain area 
ephys = load("CLASE018_LAMY_HFG.mat");
ephys = ephys.zscoreEphys;

% Create column that has the trial number in it
trialNum = reshape(repmat(1:135, 4,1), 540,1);
trialNum = num2cell(trialNum);

% Concatenate the new column to the existing data
ephysTrial = [ephys, trialNum];
