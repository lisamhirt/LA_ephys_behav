% Inputs example %
tempPtID = 'CLASE026';
% trialType = 'LA'; or 'RA'
trialType = 'LA';
gambleType = {'gamble', 'alt'};
% gambleType = {'gamble'};
% gambleType = {'alt'};

% Define outcomeType as a cell array of strings
outcomeType = {'loss', 'noChange', 'gain'};
% outcomeType = {'gain'};

Hemi = 'Left';
% brainArea = {'RAH', 'RPH'};
brainArea = {'RAMY'};

% Hemi = 'Left';
% brainArea = {'LAMY', 'LAH', 'LPH'};

epochINT = {'Start', 'Decision', 'Response', 'Outcome'};

% Create paths and add folders to path
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer
PCname = getenv('COMPUTERNAME');

switch PCname
    case 'DLPFC' % laptop
        synologyCD = 'Z:\LossAversion\Patient folders'; % Synology path
        ephysCD = 'Z:\LossAversion\LH_tempSave';
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
        LA_AN_rep = num2cell(reshape(repmat(LA_AN', 4, 1), [], 1));

    end % if else / gamble or alternative
end % for / gii / gamble type

%% Create tables for each variable
% Fix this part at a later date - add gamble and alternative and fix the if
% else 

if exist("LA_GL_rep", 'var') && exist('LA_GG_rep', 'var') && exist('LA_AN_rep', 'var')
    tmpCell = [LA_Gamble_rep, LA_Alt_rep, LA_GL_rep, LA_GG_rep, LA_AN_rep];
    tmpBehavTab = cell2table(tmpCell, "VariableNames",["Gamble" "Alternative" "GambleLoss" "GambleGain" "AltNeutral"]);

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

%% add ephys to behavioral tables
% This isn't working for whatever reason. Ask JAT
% Loop through all three in a for loop

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

if exist("ephys1Tab", 'var')
    epochEphys1 = innerSwarm_v2(ephys1Tab, epochINT);

elseif exist("ephys2Tab", 'var')
    epochEphys2 = innerSwarm_v2(ephys2Tab, epochINT);

else exist("ephys3Tab", 'var')
    epochEphys3 = innerSwarm_v2(ephys3Tab, epochINT);
end % if else / ephysTabs exist


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

% title('Start Epoch - Amy')
xlim([0 3])
xticks(1:2)
xticklabels({'Gamble Gain', 'Gamble Loss'})
% xticks(1:length(datasets))
% xticklabels({'GGStart', 'GLStart', 'GGStart 2'}) % Update based on actual data labels

hold off
%% 2 brain areas
datasets = {epochEphys1.GGOut, epochEphys2.GGOut, epochEphys1.GLOut, epochEphys2.GLOut, ...
    epochEphys1.ANOut, epochEphys2.ANOut};
colors = {'green', 'blue', 'green', 'blue', 'green', 'blue'};
xOffsets = [-0.2, 0.2, 0.8, 1.2, 1.8, 2.2]; % Adjust based on the number of datasets

figure;
hold on

% Initialize a cell array to store y values
y_values = cell(1, length(datasets));
y_names = {'E1_GGout','E2_GGout', 'E1_GLout', 'E2_GLout', 'E1_ANout', 'E2_ANout'};

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    % Save y values in the cell array
    y_values{i} = y;

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
    line([x(1) - 0.1, x(1) + 0.1], [quantile(y, 0.75), quantile(y, 0.75)], 'Color', 'k', 'LineWidth', 2);
end

title('Outcome Epoch')
xlim([0 4])
xticks(1:3)
xticklabels({'Gamble Gain', 'Gamble Loss', 'Alternative Neutral'})

hold off

%% 3 Brain areas - outcome epoch

datasets = {epochEphys1.GGOut, epochEphys2.GGOut, epochEphys3.GGOut, ...
    epochEphys1.GLOut, epochEphys2.GLOut, epochEphys3.GLOut, ...
    epochEphys1.ANOut, epochEphys2.ANOut, epochEphys3.ANOut};
colors = {'green', 'blue','m', 'green', 'blue', 'm', 'green', 'blue', 'm'};
% xOffsets = [-0.2, 0.2, 0.6, 1.2, 1.8, 2.2, 2.8, 3.2, 3.6]; % Adjust based on the number of datasets
xOffsets = [-0.6, -0.2, 0.2, 0.8, 1.2, 1.6, 2.4, 3.0, 3.4]; % Adjust based on the number of datasets

figure;
hold on

% Initialize a cell array to store y values
y_values = cell(1, length(datasets));
y_names = {'E1_GGout','E2_GGout', 'E3_GGout', 'E1_GLout', 'E2_GLout', 'E3_GLout',...
    'E1_ANout', 'E2_ANout', 'E3_ANout'};

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    % Save y values in the cell array
    y_values{i} = y;

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
    line([x(1) - 0.1, x(1) + 0.1], [quantile(y, 0.75), quantile(y, 0.75)], 'Color', 'k', 'LineWidth', 2);
end

title('Outcome Epoch')
xlim([0 5])
% xticks(1:3)
xticks([mean(xOffsets(1:3)), mean(xOffsets(4:6)), mean(xOffsets(7:9))])
xticklabels({'Gamble Gain', 'Gamble Loss', 'Alternative Neutral'})

hold off




%% Stats
yStats = [y_names; y_values]; % concatenate y values with variable names

%%
%
[~, pval] = kstest2(yStats{2,2}, yStats{2,3})



%%
tmpYvars = struct;

[~,pval] =kstest2(tmpYvars.E2GL, tmpYvars.E2AN)

[~,pval] =kstest2(y1, y2)


%% 3 Brain areas - Start epoch

datasets = {epochEphys1.GGStart, epochEphys2.GGStart, epochEphys3.GGStart, ...
    epochEphys1.GLStart, epochEphys2.GLStart, epochEphys3.GLStart, ...
    epochEphys1.ANStart, epochEphys2.ANStart, epochEphys3.ANStart};
colors = {'green', 'blue','m', 'green', 'blue', 'm', 'green', 'blue', 'm'};
% xOffsets = [-0.2, 0.2, 0.6, 1.2, 1.8, 2.2, 2.8, 3.2, 3.6]; % Adjust based on the number of datasets
xOffsets = [-0.6, -0.2, 0.2, 0.8, 1.2, 1.6, 2.4, 3.0, 3.4]; % Adjust based on the number of datasets

figure;
hold on

% Initialize a cell array to store y values
y_values = cell(1, length(datasets));
y_names = {'E1_GGstart','E2_GGstart', 'E3_GGstart', 'E1_GLstart', 'E2_GLstart', ...
    'E3_GLstart', 'E1_ANstart', 'E2_ANstart', 'E3_ANstart'};

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    % Save y values in the cell array
    y_values{i} = y;

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
    line([x(1) - 0.1, x(1) + 0.1], [quantile(y, 0.75), quantile(y, 0.75)], 'Color', 'k', 'LineWidth', 2);
end

title('Start Epoch')
xlim([0 5])
% xticks(1:3)
xticks([mean(xOffsets(1:3)), mean(xOffsets(4:6)), mean(xOffsets(7:9))])
xticklabels({'Gamble Gain', 'Gamble Loss', 'Alternative Neutral'})

hold off
%%
yStats = [y_names; y_values]; % concatenate y values with variable names

%%
% Electrode 1 vs itself
[~, pval1] = kstest2(yStats{2,1}, yStats{2,4})
[~, pval2] = kstest2(yStats{2,1}, yStats{2,7})
[~, pval3] = kstest2(yStats{2,4}, yStats{2,7})

%%
% Electrode 2 vs itself
[~, pval1] = kstest2(yStats{2,2}, yStats{2,5})
[~, pval2] = kstest2(yStats{2,2}, yStats{2,8})
[~, pval3] = kstest2(yStats{2,5}, yStats{2,8})

%%
% Electrode 3 vs itself
[~, pval1] = kstest2(yStats{2,3}, yStats{2,6})
[~, pval2] = kstest2(yStats{2,3}, yStats{2,9})
[~, pval3] = kstest2(yStats{2,6}, yStats{2,9})

%%
% Electrode 1 vs electrode 2
[~, pval1] = kstest2(yStats{2,1}, yStats{2,2}) % GG
[~, pval2] = kstest2(yStats{2,1}, yStats{2,5})
[~, pval3] = kstest2(yStats{2,1}, yStats{2,8})
[~, pval4] = kstest2(yStats{2,4}, yStats{2,2})
[~, pval5] = kstest2(yStats{2,4}, yStats{2,5})
[~, pval6] = kstest2(yStats{2,4}, yStats{2,8})
[~, pval7] = kstest2(yStats{2,7}, yStats{2,2})
[~, pval8] = kstest2(yStats{2,7}, yStats{2,5})
[~, pval9] = kstest2(yStats{2,7}, yStats{2,8})

%%
% Elec 1 vs elec 3
[~, pval1] = kstest2(yStats{2,1}, yStats{2,3})
[~, pval2] = kstest2(yStats{2,1}, yStats{2,6})
[~, pval3] = kstest2(yStats{2,1}, yStats{2,9})
[~, pval4] = kstest2(yStats{2,4}, yStats{2,3})
[~, pval5] = kstest2(yStats{2,4}, yStats{2,6})
[~, pval6] = kstest2(yStats{2,4}, yStats{2,9})
[~, pval7] = kstest2(yStats{2,7}, yStats{2,3})
[~, pval8] = kstest2(yStats{2,7}, yStats{2,6})
[~, pval9] = kstest2(yStats{2,7}, yStats{2,9})

%% Elec 2 vs 3

[~, pval1] = kstest2(yStats{2,2}, yStats{2,3}) % GG
[~, pval2] = kstest2(yStats{2,2}, yStats{2,6})
[~, pval3] = kstest2(yStats{2,2}, yStats{2,9})
[~, pval4] = kstest2(yStats{2,5}, yStats{2,3})
[~, pval5] = kstest2(yStats{2,5}, yStats{2,6})
[~, pval6] = kstest2(yStats{2,5}, yStats{2,9})
[~, pval7] = kstest2(yStats{2,8}, yStats{2,3})
[~, pval8] = kstest2(yStats{2,8}, yStats{2,6})
[~, pval9] = kstest2(yStats{2,8}, yStats{2,9})



%% 3 Brain areas - Response epoch

datasets = {epochEphys1.GGRes, epochEphys2.GGRes, epochEphys3.GGRes, ...
    epochEphys1.GLRes, epochEphys2.GLRes, epochEphys3.GLRes, ...
    epochEphys1.ANRes, epochEphys2.ANRes, epochEphys3.ANRes};
colors = {'green', 'blue','m', 'green', 'blue', 'm', 'green', 'blue', 'm'};
% xOffsets = [-0.2, 0.2, 0.6, 1.2, 1.8, 2.2, 2.8, 3.2, 3.6]; % Adjust based on the number of datasets
xOffsets = [-0.6, -0.2, 0.2, 0.8, 1.2, 1.6, 2.4, 3.0, 3.4]; % Adjust based on the number of datasets

figure;
hold on

% Initialize a cell array to store y values
y_values = cell(1, length(datasets));
y_names = {'E1_GGres','E2_GGres', 'E3_GGres', 'E1_GLres', 'E2_GLres', ...
    'E3_GLres', 'E1_ANres', 'E2_ANres', 'E3_ANres'};

for i = 1:length(datasets)
    y = datasets{i}(:);
    x = ones(size(y)) + xOffsets(i);

    % Save y values in the cell array
    y_values{i} = y;

    s = swarmchart(x, y, colors{i});
    s.XJitter = "rand";
    s.XJitterWidth = 0.2;
    s.MarkerFaceAlpha = 0.4;

    % Draw a line at the median
    line([x(1) - 0.1, x(1) + 0.1], [median(y), median(y)], 'Color', 'k');
    line([x(1) - 0.1, x(1) + 0.1], [quantile(y, 0.75), quantile(y, 0.75)], 'Color', 'k', 'LineWidth', 2);
end

title('Response Epoch')
xlim([0 5])
% xticks(1:3)
xticks([mean(xOffsets(1:3)), mean(xOffsets(4:6)), mean(xOffsets(7:9))])
xticklabels({'Gamble Gain', 'Gamble Loss', 'Alternative Neutral'})

%%
yStats = [y_names; y_values]; % concatenate y values with variable names