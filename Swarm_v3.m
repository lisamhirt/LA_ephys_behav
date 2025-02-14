

% Inputs example %
tempPtID = 'CLASE018';
% shortBA = 'LAMY'; % not using? 
% trialType = 'LA'; or 'RA'
trialType = 'LA'; 
gambleType = {'gamble', 'alt'};
% gambleType = {'gamble'};
% gambleType = {'alt'};

% Define outcomeType as a cell array of strings
outcomeType = {'loss', 'noChange', 'gain'};
% outcomeType = {'gain'};

Hemi = 'Left'; 
brainArea = {'LAMY', 'LAH'};

epochINT = {'Start', 'Decision', 'Response', 'Outcome'};




% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer
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

% renamed gainLOSS_trials to LA_trials
% renamed gainONLY_trials to RA_trials

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
% Gamble
% gamble_trials = eventTab.subjdata.cs.choice == 1 & ~checkIndex;
% % Alternative
% alternative_trials = eventTab.subjdata.cs.choice == 0 & ~checkIndex;
% % Outcome Loss
% outcomeLoss = eventTab.subjdata.cs.outcome < 0 & ~checkIndex;
% % Outcome no change
% outcomeNeutral = eventTab.subjdata.cs.outcome == 0 & ~checkIndex;
% % Outcome gain
% outcomeGain = eventTab.subjdata.cs.outcome > 0 & ~checkIndex;

% copy variables
% gainLossTrials = LA_trials;
% gambleTrials = gamble_trials;
% outcomeLossTrial = outcomeLoss;
% outcomeGainTrial = outcomeGain;

%% find what trials they gambled on, then if they won or loss
% start with gain loss trials since i only care about those and see what
% gain loss trials they decided to gamble on 

% Didn't use these variables below again 
% gainLoss_gambled = find(all(gainLossTrials & gambleTrials, 2)); % gives me the rows that they gambled on a gain loss trial

% see if they won (gained) on their gamble. 1 means yes they gained 0 means no
% gainLoss_gamble_outcomeGain= outcomeGainTrial(gainLoss_gambled); 

% see if they loss on their gamble
% gainLoss_gamble_outcomeLoss = outcomeLossTrial(gainLoss_gambled);

%%
% Find where it was a Loss aversion (LA) trial and when they gambled
% LA_Gamble = all(LA_trials & gamble_trials, 2);
% 
% % Index where it was a LA trial, they gambled, and they won (gained)
% LA_GG = all(LA_Gamble & outcomeGain, 2);
% 
% % Index where it was a LA trial, they gambled, and they loss
% LA_GL = all(LA_Gamble & outcomeLoss, 2);


%%
% Gamble type / if they gamble or took the alternative %

for gii = 1:length(gambleType)
    if strcmpi('gamble', gambleType{gii})
        LA_Gamble = all(LA_trials & gamble_trials, 2); % LA and when they gambled

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

        LA_AN = all(LA_Alt & outcomeNeutral, 2); % LA, alternative, and no change outcome

        % Create column that has if was LA_GL repeated
        LA_AN_rep = num2cell(reshape(repmat(LA_AN', 4, 1), [], 1));

    end % if else / gamble or alternative
end % for / gii / gamble type



%% Create tables for each variable

if exist("LA_GL_rep", 'var') && exist('LA_GG_rep', 'var') && exist('LA_AN_rep', 'var')
    tmpCell = [LA_GL_rep, LA_GG_rep, LA_AN_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["GambleLoss" "GambleGain" "AltNeutral"]);

elseif exist("LA_GL_rep", 'var') && exist('LA_GG_rep', 'var')
    tmpCell = [LA_GL_rep, LA_GG_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["GambleLoss" "GambleGain"]);

elseif exist("LA_GL_rep", 'var') && exist('LA_AN_rep', 'var')
    tmpCell = [LA_GL_rep, LA_AN_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["GambleLoss" "AltNeutral"]);

elseif exist("LA_GG_rep", 'var') && exist('LA_AN_rep', 'var')
    tmpCell = [LA_GG_rep, LA_AN_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["GambleGain" "AltNeutral"]);

elseif exist("LA_GL_rep", 'var')
    tmpCell = [LA_GL_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["GambleLoss"]);

elseif exist("LA_GG_rep", 'var')
    tmpCell = [LA_GL_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["GambleGain"]);

else exist('LA_AN_rep', 'var')
    tmpCell = [LA_AN_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["AltNeutral"]);

end % if else


%% Ephys %%
% CD to folder
tmpEphysPath = strcat(ephysCD, '\', tempPtID, '\', Hemi, '\' );
cd(tmpEphysPath)

% Load ephys per brain area
baDIR = dir;
baDIRNames = {baDIR.name};
baDIRmat = contains(baDIRNames, brainArea);
baDIRBAmatch = baDIRNames(baDIRmat);



for bai = 1:length(baDIRBAmatch)

    if bai == 1

        tmpBALoc = contains(baDIRBAmatch, brainArea{bai});
        tmpFileName = string(baDIRBAmatch(tmpBALoc));

        ephys1 = load(tmpFileName);
        ephys1 = ephys1.zscoreEphys;
        ephys1Tab = cell2table(ephys1, "VariableNames",["EpochID" "Ephys"]);

        ephys1Name = brainArea{bai};

    elseif bai == 2

        tmpBALoc = contains(baDIRBAmatch, brainArea{bai});
        tmpFileName = string(baDIRBAmatch(tmpBALoc));

        ephys2 = load(tmpFileName);
        ephys2 = ephys2.zscoreEphys;
        ephys2Tab = cell2table(ephys2, "VariableNames",["EpochID" "Ephys"]);

        ephys2Name =  brainArea{bai};

    elseif bai == 3

        tmpBALoc = contains(baDIRBAmatch, brainArea{bai});
        tmpFileName = string(baDIRBAmatch(tmpBALoc));

        ephys3 = load(tmpFileName);
        ephys3 = ephys3.zscoreEphys;
        ephys3Tab = cell2table(ephys3, "VariableNames",["EpochID" "Ephys"]);

        ephys3Name =  brainArea{bai};

    else 
        disp('Try again')

    end % if else

end % for



%% old code

% % Create column that has the trial number in it - don't need to do this
% trialNum = reshape(repmat(1:135, 4,1), 540,1);
% trialNum = num2cell(trialNum);
% 
% % Concatenate the new column to the existing data
% ephysTrial = [ephys, trialNum];
% 
% % Create column that has if it was LA_GG repeated
% LA_GG_rep = num2cell(reshape(repmat(LA_GG', 4, 1), [], 1));
% 
% % Concatenate the new column to the existing data - 4th column is LA_GG
% ephysTrial = [ephysTrial, LA_GG_rep];
% 
% % Create column that has if was LA_GL repeated
% LA_GL_rep = num2cell(reshape(repmat(LA_GL', 4, 1), [], 1));
% 
% % Concatenate the new column to the existing data - 5th column is LA_GL
% ephysTrial = [ephysTrial, LA_GL_rep];

% Make ephysTrial a table
% ephysTab = cell2table(ephysTrial, "VariableNames", ["EpochID" "Ephys" "TrialNum" "GambleGain" "GambleLoss"]);

%% add ephys to behavioral tables 
% This isn't working for whatever reason. Ask JAT

if exist("ephys1Tab", 'var')
    ephys1Tab = [ephys1Tab, tmpBehavTab];

elseif exist("ephys2Tab", 'var')
    ephys2Tab = [ephys2Tab, tmpBehavTab];

elseif exist("ephys3Tab", 'var')
    ephys3Tab = [ephys3Tab, tmpBehavTab];

else
    disp('This probably shouldnt be displayed')

end % if else

%%
% Get every row that was a gamble gain or gamble loss
% GG_tab = ephysTab(ephysTab.GambleGain == 1, :); % gamble gain
% GL_tab = ephysTab(ephysTab.GambleLoss == 1, :); % Gamble loss
% 
% % Get out epochs
% % Get every row that was a 'start' epoch for gamble gain and gamble loss
% GG_start = GG_tab(strcmp(GG_tab.EpochID, 'Start'), :);
% GL_start = GL_tab(strcmp(GL_tab.EpochID, 'Start'), :);
% 
% % Decision
% GG_dec = GG_tab(strcmp(GG_tab.EpochID, 'Decision'), :);
% GL_dec = GL_tab(strcmp(GL_tab.EpochID, 'Decision'), :);
% 
% % Response
% GG_res = GG_tab(strcmp(GG_tab.EpochID, 'Response'), :);
% GL_res = GL_tab(strcmp(GL_tab.EpochID, 'Response'), :);
% 
% % Outcome
% GG_out = GG_tab(strcmp(GG_tab.EpochID, 'Outcome'), :);
% GL_out = GL_tab(strcmp(GL_tab.EpochID, 'Outcome'), :);

%%

if exist("ephys1Tab", 'var')
    epochEphys1 = innerSwarm(ephys1Tab, epochINT);

elseif exist("ephys2Tab", 'var')
    epochEphys2 = innerSwarm(ephys2Tab, epochINT);

else exist("ephys3Tab", 'var')
    epochEphys3 = innerSwarm(ephys3Tab, epochINT);
end % if else / ephysTabs exist


%%
% Temporary table
% tmpTab = GL_out;
% 
% % Remove columns that are longer than the minimum column
% minCols = min(cellfun(@(x) size(x, 2), tmpTab.Ephys));
% 
% for fi = 1:length(tmpTab.Ephys)
%     currentData = tmpTab.Ephys{fi};
%     if size(currentData,2) > minCols
%         % Remove columns that exceed minCols
%         currentData(:, minCols+1:end) = [];
%     end % if else
% 
%     tmpTab.Ephys{fi} = currentData;
% 
% end % for
%%
% Save cell2mat with temporary variable
% GGStartEphys = cell2mat(tmpTab.Ephys)';
% GLStartEphys = cell2mat(tmpTab.Ephys)';
% 
% GGDecEphys = cell2mat(tmpTab.Ephys)';
% GLDecEphys = cell2mat(tmpTab.Ephys)';
% 
% GGResEphys = cell2mat(tmpTab.Ephys)';
% GLResEphys = cell2mat(tmpTab.Ephys)';
% 
% GGOutEphys = cell2mat(tmpTab.Ephys)';
% GLOutEphys = cell2mat(tmpTab.Ephys)';

%% Plotting %% 

% Define datasets
datasets = {epochEphys1.GGStart, epochEphys1.GLStart, epochEphys1.ANStart};
colors = {'green', 'red', 'blue'};
xOffsets = [-0.4, 0, 0.4]; % Adjust based on the number of datasets

figure;
hold on

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
end

title('Start Epoch - Amy')
xlim([0 3])
xticks(1)
xticklabels('Start')
% xticks(1:length(datasets))
% xticklabels({'GGStart', 'GLStart', 'GGStart 2'}) % Update based on actual data labels

hold off

%%
datasets = {epochEphys1.GGStart, epochEphys2.GGStart, epochEphys1.GLStart, epochEphys2.GLStart};
colors = {'green', 'red', 'blue', 'cyan'};
xOffsets = [-0.4, 0, 1, 1.4]; % Adjust based on the number of datasets

figure;
hold on

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
end

title('Start Epoch - Amy')
xlim([0 3])
xticks(1:2)
xticklabels({'Gamble Gain', 'Gamble Loss'})
% xticks(1:length(datasets))
% xticklabels({'GGStart', 'GLStart', 'GGStart 2'}) % Update based on actual data labels

hold off
%%
datasets = {epochEphys1.GGOut, epochEphys2.GGOut, epochEphys1.GLOut, epochEphys2.GLOut, ... 
    epochEphys1.ANOut, epochEphys2.ANOut};
colors = {'green', 'blue', 'green', 'blue', 'green', 'blue'};
xOffsets = [-0.2, 0.2, 0.8, 1.2, 1.8, 2.2]; % Adjust based on the number of datasets

figure;
hold on

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
end

title('Outcome Epoch')
xlim([0 4])
xticks(1:3)
xticklabels({'Gamble Gain', 'Gamble Loss', 'Alternative Neutral'})


hold off


%% 
tmpYvars = struct;

[~,pval] =kstest2(tmpYvars.E1GG, tmpYvars.E1GG)

%% Plotting %%
% Start Epoch %
% GG Start
% Create a vector for x-values (column indices)
% First input is number of trials and the second is ephys data
% x1 = repmat(1:40, 989, 1);

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
% x2 = repmat(1:48, 991, 1);

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
figure;
s1 = swarmchart(x1,y1,'green');
s1.XJitter = "rand";
s1.XJitterWidth = .2;
s1.MarkerFaceAlpha = 0.4;
hold on

line([.7 .9],[(median(y1)) (median(y1))],'Color', 'k');

s2 = swarmchart(x2,y2,'red');
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