%% Behavior %%
% Get behavior / gambling info 
cd('Z:\LossAversion\Patient folders\CLASE018\Behavioral-data'); % CD to patient folder

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
% outcomeNeutral = eventTab.subjdata.cs.outcome == 0 & ~checkIndex;
% Outcome gain
outcomeGain = eventTab.subjdata.cs.outcome > 0 & ~checkIndex;

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

% Find where it was a Loss aversion (LA) trial and when they gambled 
LA_Gamble = all(gainLossTrials & gambleTrials, 2);

% Index where it was a LA trial, they gambled, and they won (gained)
LA_GG = all(LA_Gamble & outcomeGainTrial,2);

% Index where it was a LA trial, they gambled, and they loss 
LA_GL = all(LA_Gamble & outcomeLossTrial,2);


%% Ephys %%

% CD to folder 
cd('Z:\LossAversion\LH_tempSave\CLASE018\Left');

% Load ephys per brain area 
% Anterior Hippocampus
ephysHP = load("CLASE018_LPH_HFG.mat");
ephysHP = ephysHP.zscoreEphys;

% Create column that has the trial number in it
trialNumHP = reshape(repmat(1:135, 4,1), 540,1);
trialNumHP = num2cell(trialNumHP);

% Concatenate the new column to the existing data
ephysTrialHP = [ephysHP, trialNumHP];

% Create column that has if it was LA_GG repeated 
LA_GG_repHP = num2cell(reshape(repmat(LA_GG', 4, 1), [], 1));

% Concatenate the new column to the existing data - 4th column is LA_GG
ephysTrialHP = [ephysTrialHP, LA_GG_repHP];

% Create column that has if was LA_GL repeated 
LA_GL_repHP = num2cell(reshape(repmat(LA_GL', 4, 1), [], 1));

% Concatenate the new column to the existing data - 5th column is LA_GL
ephysTrialHP = [ephysTrialHP, LA_GL_repHP];

% Make ephysTrial a table 
ephysTabHP = cell2table(ephysTrialHP, "VariableNames", ["EpochID" "Ephys" "TrialNum" "GambleGain" "GambleLoss"]);

%%
% Get every row that was a gamble gain or gamble loss 
GG_tabHP = ephysTabHP(ephysTabHP.GambleGain == 1, :); % gamble gain 
GL_tabHP = ephysTabHP(ephysTabHP.GambleLoss == 1, :); % Gamble loss 
 
% Get out epochs 
% Get every row that was a 'start' epoch for gamble gain and gamble loss 
GG_startHP = GG_tabHP(strcmp(GG_tabHP.EpochID, 'Start'), :);
GL_startHP = GL_tabHP(strcmp(GL_tabHP.EpochID, 'Start'), :);

% Decision 
GG_decHP = GG_tabHP(strcmp(GG_tabHP.EpochID, 'Decision'), :);
GL_decHP = GL_tabHP(strcmp(GL_tabHP.EpochID, 'Decision'), :);

% Response 
GG_resHP = GG_tabHP(strcmp(GG_tabHP.EpochID, 'Response'), :);
GL_resHP = GL_tabHP(strcmp(GL_tabHP.EpochID, 'Response'), :);

% Outcome 
GG_outHP = GG_tabHP(strcmp(GG_tabHP.EpochID, 'Outcome'), :);
GL_outHP = GL_tabHP(strcmp(GL_tabHP.EpochID, 'Outcome'), :);
%%
% Temporary table 
tmpTab = GL_outHP;

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
%%
% Save cell2mat with temporary variable
GGStartEphysHP = cell2mat(tmpTab.Ephys)';
GLStartEphysHP = cell2mat(tmpTab.Ephys)';

GGDecEphysHP = cell2mat(tmpTab.Ephys)';
GLDecEphysHP = cell2mat(tmpTab.Ephys)'; 

GGResEphysHP = cell2mat(tmpTab.Ephys)';
GLResEphysHP = cell2mat(tmpTab.Ephys)';

GGOutEphysHP = cell2mat(tmpTab.Ephys)';
GLOutEphysHP = cell2mat(tmpTab.Ephys)';

%% Plotting %%
% Start Epoch %
% GG Start 
% Create a vector for x-values (column indices)
% First input is number of trials and the second is ephys data 
x1HP = repmat(1:40, 989, 1);

% Reshape the data into column vectors
x1HP = x1HP(:);
y1HP = GGStartEphysHP(:);

% Create the swarm chart
% figure;
% swarmchart(x1, y1);
% xlabel('Trial');
% ylabel('Ephys');
% title('Swarm Chart of Start Epoch in amygdala');

% GL Start 

% Create a vector for x-values (column indices)
x2HP = repmat(1:48, 991, 1);

% Reshape the data into column vectors
x2HP = x2HP(:);
y2HP = GLStartEphysHP(:);

% Create the swarm chart
% figure;
% swarmchart(x2, y2);
% xlabel('Trial');
% ylabel('Ephys');
% title('Swarm Chart of Start Epoch in amygdala');
%% Plot GG and GL Start epoch together 
figure; 
swarmchart(x1HP,y1HP,'green')
hold on 
swarmchart(x2HP,y2HP,'red')
hold on 
title('Start Epoch - LPH')

%% Decision 
% GG Decision 
% Create x 
xGGdecHP = repmat(1:40, 9, 1);

% Reshape the data into column vectors
xGGdecHP = xGGdecHP(:);
yGGdecHP = GGDecEphysHP(:);

% GL Decision 
% Create x 
xGLdecHP = repmat(1:48, 3, 1);

% Reshape the data into column vectors
xGLdecHP = xGLdecHP(:);
yGLdecHP = GLDecEphysHP(:);

%%
% Decision Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGdecHP, yGGdecHP, 'green');
hold on
swarmchart(xGLdecHP, yGLdecHP, 'red');
hold on 
title('Decision Epoch - LPH')

%% Response 
% GG Response 
% Create x 
xGGresHP = repmat(1:40, 497, 1);

% Reshape the data into column vectors
xGGresHP = xGGresHP(:);
yGGresHP = GGResEphysHP(:);

% GL Response  
% Create x 
xGLresHP = repmat(1:48, 499, 1);

% Reshape the data into column vectors
xGLresHP = xGLresHP(:);
yGLresHP = GLResEphysHP(:);

%%
% Response Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGresHP, yGGresHP, 'green');
hold on
swarmchart(xGLresHP, yGLresHP, 'red');
hold on 
title('Response Epoch - LPH')

%% Outcome

% GG Outcome 
% Create x 
xGGoutHP = repmat(1:40, 496, 1);

% Reshape the data into column vectors
xGGoutHP = xGGoutHP(:);
yGGoutHP = GGOutEphysHP(:);

% GL Outcome  
% Create x 
xGLoutHP = repmat(1:48, 494, 1);

% Reshape the data into column vectors
xGLoutHP = xGLoutHP(:);
yGLoutHP = GLOutEphysHP(:);

%%
% Outcome Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGoutHP, yGGoutHP, 'green');
hold on
swarmchart(xGLoutHP, yGLoutHP, 'red');
hold on 
title('Outcome Epoch - LPH')