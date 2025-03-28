% Meeting with JAT on 3/25 
% JAT showed me what settings to use for the PSD to then use in FOOOF. Below 
% are the pwelch settings to use for my Nebraska and Loss Aversion data. 

pwelch(data, hamming(128), 64, 512, 500);

pwelch(GGoutMean, hamming(128), 64, 512, 500); % GGoutMean was from loss aversion 