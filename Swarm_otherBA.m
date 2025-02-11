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
ephysH = load("CLASE018_LAH_HFG.mat");
ephysH = ephysH.zscoreEphys;

% Create column that has the trial number in it
trialNumH = reshape(repmat(1:135, 4,1), 540,1);
trialNumH = num2cell(trialNumH);

% Concatenate the new column to the existing data
ephysTrialH = [ephysH, trialNumH];

% Create column that has if it was LA_GG repeated 
LA_GG_repH = num2cell(reshape(repmat(LA_GG', 4, 1), [], 1));

% Concatenate the new column to the existing data - 4th column is LA_GG
ephysTrialH = [ephysTrialH, LA_GG_repH];

% Create column that has if was LA_GL repeated 
LA_GL_repH = num2cell(reshape(repmat(LA_GL', 4, 1), [], 1));

% Concatenate the new column to the existing data - 5th column is LA_GL
ephysTrialH = [ephysTrialH, LA_GL_repH];

% Make ephysTrial a table 
ephysTabH = cell2table(ephysTrialH, "VariableNames", ["EpochID" "Ephys" "TrialNum" "GambleGain" "GambleLoss"]);

%%
% Get every row that was a gamble gain or gamble loss 
GG_tabH = ephysTabH(ephysTabH.GambleGain == 1, :); % gamble gain 
GL_tabH = ephysTabH(ephysTabH.GambleLoss == 1, :); % Gamble loss 
 
% Get out epochs 
% Get every row that was a 'start' epoch for gamble gain and gamble loss 
GG_startH = GG_tabH(strcmp(GG_tabH.EpochID, 'Start'), :);
GL_startH = GL_tabH(strcmp(GL_tabH.EpochID, 'Start'), :);

% Decision 
GG_decH = GG_tabH(strcmp(GG_tabH.EpochID, 'Decision'), :);
GL_decH = GL_tabH(strcmp(GL_tabH.EpochID, 'Decision'), :);

% Response 
GG_resH = GG_tabH(strcmp(GG_tabH.EpochID, 'Response'), :);
GL_resH = GL_tabH(strcmp(GL_tabH.EpochID, 'Response'), :);

% Outcome 
GG_outH = GG_tabH(strcmp(GG_tabH.EpochID, 'Outcome'), :);
GL_outH = GL_tabH(strcmp(GL_tabH.EpochID, 'Outcome'), :);
%%
% Temporary table 
tmpTab = GL_outH;

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
GGStartEphysH = cell2mat(tmpTab.Ephys)';
GLStartEphysH = cell2mat(tmpTab.Ephys)';

GGDecEphysH = cell2mat(tmpTab.Ephys)';
GLDecEphysH = cell2mat(tmpTab.Ephys)'; 

GGResEphysH = cell2mat(tmpTab.Ephys)';
GLResEphysH = cell2mat(tmpTab.Ephys)';

GGOutEphysH = cell2mat(tmpTab.Ephys)';
GLOutEphysH = cell2mat(tmpTab.Ephys)';

%% Plotting %%
% Start Epoch %
% GG Start 
% Create a vector for x-values (column indices)
% First input is number of trials and the second is ephys data 
x1H = repmat(1:60, 989, 1);

% Reshape the data into column vectors
x1H = x1H(:);
y1H = GGStartEphysH(:);

% Create the swarm chart
% figure;
% swarmchart(x1, y1);
% xlabel('Trial');
% ylabel('Ephys');
% title('Swarm Chart of Start Epoch in amygdala');

% GL Start 

% Create a vector for x-values (column indices)
x2H = repmat(1:72, 991, 1);

% Reshape the data into column vectors
x2H = x2H(:);
y2H = GLStartEphysH(:);

% Create the swarm chart
% figure;
% swarmchart(x2, y2);
% xlabel('Trial');
% ylabel('Ephys');
% title('Swarm Chart of Start Epoch in amygdala');
%% Plot GG and GL Start epoch together 
figure; 
swarmchart(x1H,y1H,'green')
hold on 
swarmchart(x2H,y2H,'red')
hold on 
title('Start Epoch - LAH')

%% Decision 
% GG Decision 
% Create x 
xGGdecH = repmat(1:60, 9, 1);

% Reshape the data into column vectors
xGGdecH = xGGdecH(:);
yGGdecH = GGDecEphysH(:);

% GL Decision 
% Create x 
xGLdecH = repmat(1:72, 3, 1);

% Reshape the data into column vectors
xGLdecH = xGLdecH(:);
yGLdecH = GLDecEphysH(:);

%%
% Decision Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGdecH, yGGdecH, 'green');
hold on
swarmchart(xGLdecH, yGLdecH, 'red');
hold on 
title('Decision Epoch - LAH')

%% Response 
% GG Response 
% Create x 
xGGresH = repmat(1:60, 497, 1);

% Reshape the data into column vectors
xGGresH = xGGresH(:);
yGGresH = GGResEphysH(:);

% GL Response  
% Create x 
xGLresH = repmat(1:72, 499, 1);

% Reshape the data into column vectors
xGLresH = xGLresH(:);
yGLresH = GLResEphysH(:);

%%
% Response Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGresH, yGGresH, 'green');
hold on
swarmchart(xGLresH, yGLresH, 'red');
hold on 
title('Response Epoch - LAH')

%% Outcome

% GG Outcome 
% Create x 
xGGoutH = repmat(1:60, 496, 1);

% Reshape the data into column vectors
xGGoutH = xGGoutH(:);
yGGoutH = GGOutEphysH(:);

% GL Outcome  
% Create x 
xGLoutH = repmat(1:72, 494, 1);

% Reshape the data into column vectors
xGLoutH = xGLoutH(:);
yGLoutH = GLOutEphysH(:);

%%
% Outcome Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGoutH, yGGoutH, 'green');
hold on
swarmchart(xGLoutH, yGLoutH, 'red');
hold on 
title('Outcome Epoch - LAH')