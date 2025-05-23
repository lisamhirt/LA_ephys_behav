%% Order of scripts 
% Scripts are in folder named 'LA_ephys_behav' 
% E:\GitKraken\LA_ephys_behav
%%
% 1. CleanEphys_v2

% This code pulls in the participant's NWB file. Then pulls out the brain
% area you want, with the number of contacts you want. Then it does
% artifact rejection on the contacts, then it bipolar refrences the
% artifact rejected contacts. 

% [cleanVolts] = CleanEphys_v2(tempPtID, shortBA, std_thresh, numCon);
[cleanVolts] = CleanEphys_v2('CLASE018', 'LAMY', 6, 1:3);

% Inputs example 
% tempPtID = 'CLASE018';
% shortBA = 'LAMY';
% std_thresh = 6;

% Number of contacts of interest (1:3)
% numCon = 1:3;

% Outputs 
% cleanVolts: cleaned ephys data that has been artifact rejected and bipolar refrenced. 
% Per brain area and contacts within the brain area 

%% 

% 2. BandFiltered_Zscore

[zscoreEphys] = BandFiltered_Zscore(tempPtID, Freq, cleanVolts);

% Inputs example
% tempPtID = 'CLASE018';
% Freq = [50 150];
% cleanVolts = created from CleanEphys script 

% Create paths and add folders to path %
% Create CD paths based on computer names
% Before running script, make sure synology drive is on computer

% Save %%
% Have been saving the output in LH_tempsae\ParticipantID

% EG: Z:\LossAversion\LH_tempSave\CLASE018

%%

% 3. Swarm_v5 
% - there is an inner functiokn called 'innerSwarm_v3' you need to use

% Saving the output (epochEphys1 or whatever number of contact) 
% from this in LH_Data\SwarmOutput\PartID\Hemisphere 
% EG: Z:\LossAversion\LH_Data\SwarmOutput\CLASE018\Left

%% Swarmoutput Inner folder 

% 4. createTabfromSwarm 

% Creates a table for each brain area per hemisphere. Need to load
% electrodes from number 3. Save each brain area in a table, then
% concatenate all the tables. Then save the concatenated table as a csv
% file to do stats on 

%% FOOOF %% 

% 1. FOOOF_start_v1 

% In this script there are inner functions that will do processing. It runs
% CleanEphys_v2, then it creates epochs for ephys, then it separates the
% ephys per epochs and if it was gambling / alternative. This creates the
% allLFPtab variable 

% 2. FOOOF_epochs.m
% This runs FOOOF on allLFPtab and on epochs (start, response, outcome) and
% if it was a gg or gl or an. at the very bottom there is a function to
% create a column that says if that peak frequency from FOOOF was delta,
% theta, alpha etc. 


%% Other scripts %

% scatterPlots.m
% this script will run FOOOF and create a scatter plot for an epoch (start,
% outcome, etc) and if it was a gg or alternative 

% scatterPlots_density.m
% same thing as scatterPlots, just a different scatter plot that shows
% density of the peak frequency from FOOOF

% FOOOF_tableCreate.m
% This creates a table from all of the FOOOF outputs I saved from
% scatterPlots

