
% allLFPtab is taken from FOOOF_start_v1 
allLFPtabCOPY = allLFPtab;

% Create an array with numbers 1 through 135 that are repeated 4 times each
tmpCol = repmat(1:135, 4, 1);

% Reshape the array to be a single row
tmpCol = tmpCol(:);

% Make tmpCol a table 
tmpCol = table(tmpCol,'VariableNames',{'TrialNum'});

% Add tmpCol to allLFPtab 
allLFPtab = [allLFPtab tmpCol];

% Find where all GG/GL/AN occured 

% find where all outcomes occured %
% Find the rows where the EpochID column is "Outcome"
rowsWithOutcome = strcmp(allLFPtab.EpochID, "Outcome");

% Extract those rows from the table
tmpOut = allLFPtab(rowsWithOutcome, :);

%% Sankey try 

% Gamble Gain 
% Extract GG rows 
GGidx = tmpOut.GambleGain;
GGTab = tmpOut(GGidx,:);

% Convert table to cell 
GamCell = num2cell(GGTab.Gamble);
GGCell = num2cell(GGTab.GambleGain);

onesGGcell = GamCell;

% Replace 1 with 'Gamble' or 'GG'
GamCell(GGTab.Gamble == 1) = {'Gamble'};
GGCell(GGTab.GambleGain == 1) = {'GG'};

% Combine them together 
GGcellCombine = [GamCell GGCell onesGGcell];

% Gamble Loss 
% extract GL rows 
GLidx = tmpOut.GambleLoss;
GLTab = tmpOut(GLidx, :);

GamCell2 = num2cell(GLTab.Gamble);
GLCell = num2cell(GLTab.GambleLoss);

onesGLcell = GamCell2;

% replace 
GamCell2(GLTab.Gamble == 1) = {'Gamble'};
GLCell(GLTab.GambleLoss == 1) = {'GL'};

% combine 
GLcellCombine = [GamCell2 GLCell onesGLcell];

% All gamble combine 
allGam = [GGcellCombine; GLcellCombine];

% Alt 
Altidx = tmpOut.Alternative;
ALtab = tmpOut(Altidx, :);

AltCell = num2cell(ALtab.Alternative);
AltOutCell = AltCell;

onesALcell = AltCell;

% replace 
AltCell(ALtab.Alternative == 1) = {'Alt'};
AltOutCell(ALtab.Alternative == 1) = {'AltOUT'};

% combine
altCombine = [AltCell AltOutCell onesALcell];


% Combine all data 
ALLData = [allGam; altCombine];


%%
SK=SSankey(ALLData(:,1),ALLData(:,2),ALLData(:,3));

SK.RenderingMethod='interp';  







