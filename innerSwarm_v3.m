function [cleanedTabs] = innerSwarm_v3(tmpTab, epochINT)

% Input variables %
% tmpTab - this is whatever ephys tab i'm on. Eg: ephys1Tab
% epochINT = {'Start', 'Decision', 'Response', 'Outcome'}; % also from swarm script

% Output variables %
% create a struct as the output
cleanedTabs = struct; % put all the epochs in here

% Create tables for for GG/GL/AN
if ismember('GambleLoss', tmpTab.Properties.VariableNames)
    GL_tab = tmpTab(tmpTab.GambleLoss == 1, :); % Gamble loss

    GL_out = GL_tab(strcmp(GL_tab.EpochID, 'Outcome'), :);

    % Remove columns that are longer than the minimum column
    minCols = min(cellfun(@(x) size(x, 2), GL_out.Ephys));

    for fi = 1:length(GL_out.Ephys)
        currentData = GL_out.Ephys{fi};
        if size(currentData,2) > minCols
            % Remove columns that exceed minCols
            currentData(:, minCols+1:end) = [];
        end % if else
        GL_out.Ephys{fi} = currentData;
    end % for / fi

    GLOutEphys = mean(cell2mat(GL_out.Ephys)');

    cleanedTabs.GLOut = GLOutEphys; % add data to struct

end % if / ismember

if ismember('GambleGain',tmpTab.Properties.VariableNames)
    GG_tab = tmpTab(tmpTab.GambleGain == 1, :);

    GG_out = GG_tab(strcmp(GG_tab.EpochID, 'Outcome'), :);

    % Remove columns that are longer than the minimum column
    minCols = min(cellfun(@(x) size(x, 2), GG_out.Ephys));

    for fi = 1:length(GG_out.Ephys)
        currentData = GG_out.Ephys{fi};
        if size(currentData,2) > minCols
            % Remove columns that exceed minCols
            currentData(:, minCols+1:end) = [];
        end % if else
        GG_out.Ephys{fi} = currentData;
    end % for / fi


    GGOutEphys = mean(cell2mat(GG_out.Ephys)');

    cleanedTabs.GGOut = GGOutEphys; % add data to struct

end % if / is member

if ismember('AltNeutral', tmpTab.Properties.VariableNames)
    AN_tab = tmpTab(tmpTab.AltNeutral == 1, :);

    for ei = 1:length(epochINT)

        if strcmpi('Start', epochINT{ei})
            AN_start = AN_tab(strcmp(AN_tab.EpochID, 'Start'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), AN_start.Ephys));

            for fi = 1:length(AN_start.Ephys)
                currentData = AN_start.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                AN_start.Ephys{fi} = currentData;
            end % for / fi

            ANStartEphys = mean(cell2mat(AN_start.Ephys)');

            cleanedTabs.ANStart = ANStartEphys; % add data to struct

        elseif strcmpi('Decision', epochINT{ei})

            AN_dec = AN_tab(strcmp(AN_tab.EpochID, 'Decision'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), AN_dec.Ephys));

            for fi = 1:length(AN_dec.Ephys)
                currentData = AN_dec.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                AN_dec.Ephys{fi} = currentData;
            end % for / fi


            ANDecEphys = mean(cell2mat(AN_dec.Ephys)');

            cleanedTabs.ANDec = ANDecEphys; % add data to struct

        elseif strcmpi('Response', epochINT{ei})

            AN_res = AN_tab(strcmp(AN_tab.EpochID, 'Response'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), AN_res.Ephys));

            for fi = 1:length(AN_res.Ephys)
                currentData = AN_res.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                AN_res.Ephys{fi} = currentData;
            end % for / fi


            ANResEphys = mean(cell2mat(AN_res.Ephys)');

            cleanedTabs.ANRes = ANResEphys; % add data to struct

        elseif strcmpi('Outcome', epochINT{ei})

            AN_out = AN_tab(strcmp(AN_tab.EpochID, 'Outcome'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), AN_out.Ephys));

            for fi = 1:length(AN_out.Ephys)
                currentData = AN_out.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                AN_out.Ephys{fi} = currentData;
            end % for / fi


            ANOutEphys = mean(cell2mat(AN_out.Ephys)');

            cleanedTabs.ANOut = ANOutEphys; % add data to struct
        else
            disp('your code is broke')

        end % if else / start / gamble loss

    end % for / ei / length of epochs

end % if else / alt neutral


% Only Gamble and Alternative - no outcome variable %

% Gamble
if ismember('Gamble', tmpTab.Properties.VariableNames)
    Gam_tab = tmpTab(tmpTab.Gamble == 1, :); % Gamble only

    for ei = 1:length(epochINT)

        if strcmpi('Start', epochINT{ei})
            Gam_start = Gam_tab(strcmp(Gam_tab.EpochID, 'Start'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Gam_start.Ephys));

            for fi = 1:length(Gam_start.Ephys)
                currentData = Gam_start.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Gam_start.Ephys{fi} = currentData;
            end % for / fi
            % GL_start.Ephys{fi} = currentData;
            GamStartEphys = mean(cell2mat(Gam_start.Ephys)');

            cleanedTabs.GamStart = GamStartEphys; % add data to struct

        elseif strcmpi('Decision', epochINT{ei})

            Gam_dec = Gam_tab(strcmp(Gam_tab.EpochID, 'Decision'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Gam_dec.Ephys));

            for fi = 1:length(Gam_dec.Ephys)
                currentData = Gam_dec.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Gam_dec.Ephys{fi} = currentData;
            end % for / fi

            GamDecEphys = mean(cell2mat(Gam_dec.Ephys)');

            cleanedTabs.GamDec = GamDecEphys; % add data to struct

        elseif strcmpi('Response', epochINT{ei})

            Gam_res = Gam_tab(strcmp(Gam_tab.EpochID, 'Response'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Gam_res.Ephys));

            for fi = 1:length(Gam_res.Ephys)
                currentData = Gam_res.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Gam_res.Ephys{fi} = currentData;
            end % for / fi


            GamResEphys = mean(cell2mat(Gam_res.Ephys)');

            cleanedTabs.GamRes = GamResEphys; % add data to struct


        elseif strcmpi('Outcome', epochINT{ei})

            Gam_out = Gam_tab(strcmp(Gam_tab.EpochID, 'Outcome'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Gam_out.Ephys));

            for fi = 1:length(Gam_out.Ephys)
                currentData = Gam_out.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Gam_out.Ephys{fi} = currentData;
            end % for / fi

            GamOutEphys = mean(cell2mat(Gam_out.Ephys)');

            cleanedTabs.GamOut = GamOutEphys; % add data to struct

        else
            disp('your code is broke')

        end % if else / start / gamble loss

    end % for / ei / length of epochs

end % if / ismember


% Alternative
if ismember('Alternative', tmpTab.Properties.VariableNames)
    Alt_tab = tmpTab(tmpTab.Alternative == 1, :); % Alternative only

    for ei = 1:length(epochINT)

        if strcmpi('Start', epochINT{ei})
            Alt_start = Alt_tab(strcmp(Alt_tab.EpochID, 'Start'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Alt_start.Ephys));

            for fi = 1:length(Alt_start.Ephys)
                currentData = Alt_start.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Alt_start.Ephys{fi} = currentData;
            end % for / fi
            % GL_start.Ephys{fi} = currentData;
            AltStartEphys = mean(cell2mat(Alt_start.Ephys)');

            cleanedTabs.AltStart = AltStartEphys; % add data to struct

        elseif strcmpi('Decision', epochINT{ei})

            Alt_dec = Alt_tab(strcmp(Alt_tab.EpochID, 'Decision'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Alt_dec.Ephys));

            for fi = 1:length(Alt_dec.Ephys)
                currentData = Alt_dec.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Alt_dec.Ephys{fi} = currentData;
            end % for / fi

            AltDecEphys = mean(cell2mat(Alt_dec.Ephys)');

            cleanedTabs.AltDec = AltDecEphys; % add data to struct

        elseif strcmpi('Response', epochINT{ei})

            Alt_res = Alt_tab(strcmp(Alt_tab.EpochID, 'Response'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Alt_res.Ephys));

            for fi = 1:length(Alt_res.Ephys)
                currentData = Alt_res.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Alt_res.Ephys{fi} = currentData;
            end % for / fi


            AltResEphys = mean(cell2mat(Alt_res.Ephys)');

            cleanedTabs.AltRes = AltResEphys; % add data to struct


        elseif strcmpi('Outcome', epochINT{ei})

            Alt_out = Alt_tab(strcmp(Alt_tab.EpochID, 'Outcome'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), Alt_out.Ephys));

            for fi = 1:length(Alt_out.Ephys)
                currentData = Alt_out.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                Alt_out.Ephys{fi} = currentData;
            end % for / fi

            AltOutEphys = mean(cell2mat(Alt_out.Ephys)');

            cleanedTabs.AltOut = AltOutEphys; % add data to struct

        else
            disp('your code is broke')

        end % if else / start / gamble loss

    end % for / ei / length of epochs

end % if / ismember


end % function