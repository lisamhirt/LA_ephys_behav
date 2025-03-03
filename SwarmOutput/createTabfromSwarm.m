
% Clear other variables 
clearvars -except epochEphys1 epochEphys2 epochEphys3
%%
% Create table from ephys data 
% epochEphys1

% Define the variables
allVars = {'GamStart', 'GamDec', 'GamRes', 'GGOut', 'GLOut','AltStart', 'AltDec', 'AltRes', 'AltOut'};

longVar = epochEphys1.GamStart';

% Loop through each pair of variables
for i = 1:length(allVars)
    % longVar = epochEphys1.GamStart';
    shortVar = epochEphys1.(allVars{i})';

    % Calculate the number of NaNs to add
    numNaNs = length(longVar) - length(shortVar);

    % Add NaNs to the end of altVar if needed
    if numNaNs > 0
        shortVar = [shortVar; NaN(numNaNs, 1)];
    end

    % Update the variables in the structure
    epochEphys1.(allVars{i}) = shortVar';
end

% Create the table
ephysTab = table(epochEphys1.GamStart', epochEphys1.GamDec',epochEphys1.GamRes',...
    epochEphys1.GGOut',epochEphys1.GLOut', epochEphys1.AltStart', epochEphys1.AltDec', ...
    epochEphys1.AltRes',epochEphys1.AltOut', 'VariableNames', {'gamStart', ...
    'gamDec', 'gamRes', 'gamGain', 'gamLoss', 'altStart', 'altDec', 'altRes', 'altOut'});


%% epochEphys2 

% Define the variables
allVars = {'GamStart', 'GamDec', 'GamRes', 'GGOut', 'GLOut','AltStart', 'AltDec', 'AltRes', 'AltOut'};

longVar = epochEphys2.GamStart';

% Loop through each pair of variables
for i = 1:length(allVars)
    % longVar = epochEphys2.GamStart';
    shortVar = epochEphys2.(allVars{i})';

    % Calculate the number of NaNs to add
    numNaNs = length(longVar) - length(shortVar);

    % Add NaNs to the end of altVar if needed
    if numNaNs > 0
        shortVar = [shortVar; NaN(numNaNs, 1)];
    end

    % Update the variables in the structure
    epochEphys2.(allVars{i}) = shortVar';
end

% Create the table
ephysTab = table(epochEphys2.GamStart', epochEphys2.GamDec',epochEphys2.GamRes',...
    epochEphys2.GGOut',epochEphys2.GLOut', epochEphys2.AltStart', epochEphys2.AltDec', ...
    epochEphys2.AltRes',epochEphys2.AltOut', 'VariableNames', {'gamStart', ...
    'gamDec', 'gamRes', 'gamGain', 'gamLoss', 'altStart', 'altDec', 'altRes', 'altOut'});

%% epochEphys3

% Define the variables
allVars = {'GamStart', 'GamDec', 'GamRes', 'GGOut', 'GLOut','AltStart', 'AltDec', 'AltRes', 'AltOut'};

longVar = epochEphys3.GamStart';

% Loop through each pair of variables
for i = 1:length(allVars)
    % longVar = epochEphys2.GamStart';
    shortVar = epochEphys3.(allVars{i})';
    
    % Calculate the number of NaNs to add
    numNaNs = length(longVar) - length(shortVar);
    
    % Add NaNs to the end of altVar if needed
    if numNaNs > 0
        shortVar = [shortVar; NaN(numNaNs, 1)];
    end
    
    % Update the variables in the structure
    epochEphys3.(allVars{i}) = shortVar';
end

% Create the table
ephysTab = table(epochEphys3.GamStart', epochEphys3.GamDec',epochEphys3.GamRes',...
    epochEphys3.GGOut',epochEphys3.GLOut', epochEphys3.AltStart', epochEphys3.AltDec', ...
    epochEphys3.AltRes',epochEphys3.AltOut', 'VariableNames', {'gamStart', ...
    'gamDec', 'gamRes', 'gamGain', 'gamLoss', 'altStart', 'altDec', 'altRes', 'altOut'});

%%

% Define variables
partID = {'CLASE026'};
LAscore = 1.4;
STAIS = 47;
STAIT = 45;
Hemi = {'R'};
BrainArea = {'Amy'};

longLength = 147;

% Repeat each variable 88 times (the length of the longest variable) 
partID = repmat(partID, longLength, 1);
LAscore = repmat(LAscore, longLength, 1);
STAIS = repmat(STAIS, longLength, 1);
STAIT = repmat(STAIT, longLength, 1);
Hemi = repmat(Hemi, longLength, 1);
BrainArea = repmat(BrainArea, longLength, 1);


partTab = table(partID, LAscore, STAIS, STAIT, Hemi, BrainArea);

%%
% Combine tables 
% Save in OutputTables folder
swarmOutput = [partTab ephysTab];


%% Combine all tables 

% ---- Load tables ---- 

% Left
LAMYtab = load('LAMY_tab.mat'); % loads as a struct 
LAMYtab = LAMYtab.swarmOutput;

LAHtab = load('LAH_tab.mat');
LAHtab = LAHtab.swarmOutput;

LPHtab = load('LPH_tab.mat');
LPHtab = LPHtab.swarmOutput;

AllTabLeft = [LAMYtab; LAHtab; LPHtab];
%% 
% Right 
RAMYtab = load('RAMY_tab.mat');
RAMYtab = RAMYtab.swarmOutput;

RAHtab = load('RAH_tab.mat');
RAHtab = RAHtab.swarmOutput;

RPHtab = load('RPH_tab.mat');
RPHtab = RPHtab.swarmOutput;

AllTabRight = [RAHtab; RPHtab];

%%
AllTabRight = RAMYtab;

%% Save table as CSV files 

% Left
writetable(AllTabLeft, 'CLASE026_left.csv');

% Right
writetable(AllTabRight, 'CLASE026_right.csv');

%% Save both tables 

% Save in outter folder 
% EG: Z:\LossAversion\LH_Data\SwarmOutput\CLASE018

% Load AllTabLeft and AllTabRight - save as a table and csv file

allHemiT = [AllTabLeft; AllTabRight];
writetable(allHemiT, 'CLASE026_bothHemi.csv');

%%

allPartTab = [allHemiT_CLASE018; allHemiT_CLASE024; allHemiT_CLASE026];

writetable(allPartTab, 'allPartTab.csv');