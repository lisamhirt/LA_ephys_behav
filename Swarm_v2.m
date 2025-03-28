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
% AMYGDALA
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

%%
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
%%
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
%%
% Save cell2mat with temporary variable
GGStartEphys = cell2mat(tmpTab.Ephys)';
GLStartEphys = cell2mat(tmpTab.Ephys)';

GGDecEphys = cell2mat(tmpTab.Ephys)';
GLDecEphys = cell2mat(tmpTab.Ephys)'; 

GGResEphys = cell2mat(tmpTab.Ephys)';
GLResEphys = cell2mat(tmpTab.Ephys)';

GGOutEphys = cell2mat(tmpTab.Ephys)';
GLOutEphys = cell2mat(tmpTab.Ephys)';

%% Plotting %%
% Start Epoch %
% GG Start 
% Create a vector for x-values (column indices)
% First input is number of trials and the second is ephys data 
x1 = repmat(1:40, 989, 1);

% Reshape the data into column vectors
% x1 = x1(:); 
y1 = GGStartEphys(:);
x1 = ones(size(y1))-0.2;

% Create the swarm chart
% figure;
% swarmchart(x1, y1);
% xlabel('Trial');
% ylabel('Ephys');
% title('Swarm Chart of Start Epoch in amygdala');

% GL Start 

% Create a vector for x-values (column indices)
x2 = repmat(1:48, 991, 1);

% Reshape the data into column vectors
% x2 = x2(:);
y2 = GLStartEphys(:);
x2 = ones(size(y2))+0.2;

% Create the swarm chart
% figure;
% swarmchart(x2, y2);
% xlabel('Trial');
% ylabel('Ephys');
% title('Swarm Chart of Start Epoch in amygdala');
%% Plot GG and GL Start epoch together 
% This section was written with JAT. Use this section to replicate other
% swarm charts
figure; 
s1 = swarmchart(x1,y1,'green')
s1.XJitter = "rand";
s1.XJitterWidth = .2;
s1.MarkerFaceAlpha = 0.4;
hold on 

line([.7 .9],[(median(y1)) (median(y1))],'Color', 'k');

s2 = swarmchart(x2,y2,'red')
s2.XJitter = "rand";
s2.XJitterWidth = .2;
s2.MarkerFaceAlpha = 0.4;
line([1.1 1.3],[(median(y2)) (median(y2))],'Color', 'k');

hold on 
title('Start Epoch - Amy')
xlim([0 3])
xticks([1 2])
xticklabels({'Option Screen', 'Decision Screen'})
%%
[~,pval] =kstest2(y1, y2)
%% Decision 
% GG Decision 
% Create x 
xGGdec = repmat(1:40, 9, 1);

% Reshape the data into column vectors
xGGdec = xGGdec(:);
yGGdec = GGDecEphys(:);

% GL Decision 
% Create x 
xGLdec = repmat(1:48, 3, 1);

% Reshape the data into column vectors
xGLdec = xGLdec(:);
yGLdec = GLDecEphys(:);

%%
% Decision Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGdec, yGGdec, 'green');
hold on
swarmchart(xGLdec, yGLdec, 'red');
hold on 
title('Decision Epoch - Amy')

%% Response 
% GG Response 
% Create x 
xGGres = repmat(1:40, 497, 1);

% Reshape the data into column vectors
xGGres = xGGres(:);
yGGres = GGResEphys(:);

% GL Response  
% Create x 
xGLres = repmat(1:48, 499, 1);

% Reshape the data into column vectors
xGLres = xGLres(:);
yGLres = GLResEphys(:);

%%
% Response Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGres, yGGres, 'green');
hold on
swarmchart(xGLres, yGLres, 'red');
hold on 
title('Response Epoch - Amy')

%% Outcome

% GG Outcome 
% Create x 
xGGout = repmat(1:40, 496, 1);

% Reshape the data into column vectors
xGGout = xGGout(:);
yGGout = GGOutEphys(:);

% GL Outcome  
% Create x 
xGLout = repmat(1:48, 494, 1);

% Reshape the data into column vectors
xGLout = xGLout(:);
yGLout = GLOutEphys(:);

%%
% Outcome Figure 
% Create the swarm chart
% Create the swarm chart
figure;
swarmchart(xGGout, yGGout, 'green');
hold on
swarmchart(xGLout, yGLout, 'red');
hold on 
title('Outcome Epoch - Amy')