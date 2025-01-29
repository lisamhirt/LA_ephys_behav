%% Order of scripts 
% Scripts are in folder named 'LA_ephys_behav' 
% E:\GitKraken\LA_ephys_behav
%%
% 1. CleanEphys

% This code pulls in the participant's NWB file. Then pulls out the brain
% area you want, with the number of contacts you want. Then it does
% artifact rejection on the contacts, then it bipolar refrences the
% artifact rejected contacts. 

%% 

% 2. BandFiltered_Zscore