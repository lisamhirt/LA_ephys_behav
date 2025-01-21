%% Order of scripts 
% 1. CleanEphys

% This code pulls in the participant's NWB file. Then pulls out the brain
% area you want, with the number of contacts you want. Then it does
% artifact rejection on the contacts, then it bipolar refrences the
% artifact rejected contacts. 