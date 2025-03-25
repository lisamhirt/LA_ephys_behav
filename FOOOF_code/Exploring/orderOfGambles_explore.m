
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

% 





