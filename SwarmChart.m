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
gainLoss_gambled2 = num2cell(gainLoss_gambled);

% see if they won (gained) on their gamble. 1 means yes they gained 0 means no 
gainLoss_gamble_outcomeGain= outcomeGainTrial(gainLoss_gambled); 

% see if they loss on their gamble 
gainLoss_gamble_outcomeLoss = outcomeLossTrial(gainLoss_gambled); 

%%
% Find where it was a Loss aversion (LA) trial and when they gambled 
LA_Gamble = all(gainLossTrials & gambleTrials, 2);

% Index where it was a LA trial, they gambled, and they won (gained)
LA_GG = all(LA_Gamble & outcomeGainTrial,2);

% Index where it was a LA trial, they gambled, and they loss 
LA_GL = all(LA_Gamble & outcomeLossTrial,2);

% Find if the trial is testing LA or RA. LA = 1. It repeats and is as long
% as the ephysTrial variable
% LAorRA = reshape(repmat(gainLOSS_trials', 4,1), [],1); 

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

% Create column that has if it was LA_GG repeated 
LA_GG_rep = num2cell(reshape(repmat(LA_GG', 4, 1), [], 1));

% Concatenate the new column to the existing data - 4th column is LA_GG
ephysTrial = [ephysTrial, LA_GG_rep];

% Create column that has if was LA_GL repeated 
LA_GL_rep = num2cell(reshape(repmat(LA_GL', 4, 1), [], 1));

% Concatenate the new column to the existing data - 5th column is LA_GL
ephysTrial = [ephysTrial, LA_GL_rep];

% Make ephysTrial a table 
ephysTab = cell2table(ephysTrial, "VariableNames", ["EpochID" "Ephys" "TrialNum" "GambleGain" "GambleLoss"]);


% old swarmchart plotting attempt 
% epochNames = ["Start" "Decision" "Response" "Outcome"];
% x = categorical(ephysTab.EpochID, epochNames);
% y = ephysTab.Ephys;
% 
% swarmchart(x, y)

%% Gamble gain - start epoch 
% Get every row that was a gamble gain 
GG_tab = ephysTab(ephysTab.GambleGain == 1, :);

% Get every row that was a 'start' epoch for gamble gain
GG_start = GG_tab(strcmp(GG_tab.EpochID, 'Start'), :);

% Remove columns that are longer than the minimum column
minCols = min(cellfun(@(x) size(x, 2), GG_start.Ephys));

for fi = 1:length(GG_start.Ephys)
    currentData = GG_start.Ephys{fi};
    if size(currentData,2) > minCols
        % Remove columns that exceed minCols
        currentData(:, minCols+1:end) = [];
    end % if else 

    GG_start.Ephys{fi} = currentData;

end % for 

GGStartEphys = cell2mat(GG_start.Ephys);

%% Gamble loss - start epoch 

% Get every row that was a gamble loss 
GL_tab = ephysTab(ephysTab.GambleLoss == 1, :);

% Get every row that was a 'start' epoch for gamble gain
GL_start = GL_tab(strcmp(GL_tab.EpochID, 'Start'), :);

% Remove columns that are longer than the minimum column
minCols = min(cellfun(@(x) size(x, 2), GL_start.Ephys));

for fi = 1:length(GL_start.Ephys)
    currentData = GL_start.Ephys{fi};
    if size(currentData,2) > minCols
        % Remove columns that exceed minCols
        currentData(:, minCols+1:end) = [];
    end % if else 

    GL_start.Ephys{fi} = currentData;

end % for 

GLStartEphys = cell2mat(GL_start.Ephys);

GLStartEphys_trans = GLStartEphys';

%%
% Original 
% minCols = min(cellfun(@(x) size(x, 2), GG_start.Ephys)); % Original

% Original 
% for fi = 1:length(GG_start.Ephys)
%     currentData = GG_start.Ephys{fi};
%     if size(currentData,2) > minCols
%         % Remove columns that exceed minCols
%         currentData(:, minCols+1:end) = [];
%     end % if else 
% 
%     GG_start.Ephys{fi} = currentData;
% 
% end % for 
% 
% % Original
% GGStartEphys = cell2mat(GG_start.Ephys);
% 
% 
% 
% GG_start = GG_tab(strcmp(GG_tab.EpochID, 'Start'), :);
% 
% epochNames = ["Start" "Decision" "Response" "Outcome"];


%% Plot start epoch 

% Gamble Gain - Start Epoch 
GGStartEphys_trans = GGStartEphys';

% Create a vector for x-values (column indices)
x1 = repmat(1:40, 989, 1);

% Reshape the data into column vectors
x1 = x1(:);
y1 = GGStartEphys_trans(:);

% Create the swarm chart
figure;
swarmchart(x1, y1);
xlabel('Trial');
ylabel('Ephys');
title('Swarm Chart of Start Epoch in amygdala');


%% plot gamble loss start epoch 

% Gamble Loss - Start Epoch 

% Create a vector for x-values (column indices)
x2 = repmat(1:48, 991, 1);

% Reshape the data into column vectors
x2 = x2(:);
y2 = GLStartEphys_trans(:);

% Create the swarm chart
figure;
swarmchart(x2, y2);
xlabel('Trial');
ylabel('Ephys');
title('Swarm Chart of Start Epoch in amygdala');


%% Plot both gamble gain and gamble loss start epochs
swarmchart(x1,y1,'cyan')
hold on 
swarmchart(x2,y2,'yellow')

%% Plot all epochs - make code automatic 

% Get every row that was a gamble gain or gamble loss 
GG_tab = ephysTab(ephysTab.GambleGain == 1, :); % gamble gain 
GL_tab = ephysTab(ephysTab.GambleLoss == 1, :); % Gamble loss 
 
% Get out epochs 
% Get every row that was a 'start' epoch for gamble gain and gamble loss 
GG_start = GG_tab(strcmp(GG_tab.EpochID, 'Start'), :);
GL_start = GL_tab(strcmp(GL_tab.EpochID, 'Start'), :);

% Decision 
GG_dec = GG_tab(strcmp(GG_tab.EpochID, 'Decision'), :);
GL_dec = GL_tab(strcmp(GL_tab.EpochID, 'Decision'), :);

% Response 
GG_res = GG_tab(strcmp(GG_tab.EpochID, 'Response'), :);
GL_res = GL_tab(strcmp(GL_tab.EpochID, 'Response'), :);

% Outcome 
GG_out = GG_tab(strcmp(GG_tab.EpochID, 'Outcome'), :);
GL_out = GL_tab(strcmp(GL_tab.EpochID, 'Outcome'), :);

% Temporary table 
tmpTab = GL_out;

% Remove columns that are longer than the minimum column
minCols = min(cellfun(@(x) size(x, 2), tmpTab.Ephys));

for fi = 1:length(tmpTab.Ephys)
    currentData = tmpTab.Ephys{fi};
    if size(currentData,2) > minCols
        % Remove columns that exceed minCols
        currentData(:, minCols+1:end) = [];
    end % if else 

    tmpTab.Ephys{fi} = currentData;

end % for 

% Save cell2mat with temporary variable
GGStartEphys = cell2mat(tmpTab.Ephys);
GLStartEphys = cell2mat(tmpTab.Ephys);

GGDecEphys = cell2mat(tmpTab.Ephys);
GLDecEphys = cell2mat(tmpTab.Ephys); 

GGResEphys = cell2mat(tmpTab.Ephys);
GLResEphys = cell2mat(tmpTab.Ephys);

GGOutEphys = cell2mat(tmpTab.Ephys);
GLOutEphys = cell2mat(tmpTab.Ephys);

%% plot gamble loss start epoch 

% Gamble Loss - Start Epoch 

% Create a vector for x-values (column indices)
x2 = repmat(1:48, 991, 1);

% Reshape the data into column vectors
x2 = x2(:);
y2 = GLStartEphys_trans(:);

% Create the swarm chart
figure;
swarmchart(x2, y2);
xlabel('Trial');
ylabel('Ephys');
title('Swarm Chart of Start Epoch in amygdala');