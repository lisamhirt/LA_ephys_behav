function [cleanedTabs] = innerSwarm(tmpTab, epochINT)

% Input variables %
% tmpTab - this is whatever ephys tab i'm on. Eg: ephys1Tab
% epochINT = {'Start', 'Decision', 'Response', 'Outcome'}; % also from swarm script

% Output variables %
% create a struct as the output
cleanedTabs = struct; % put all the epochs in here

% Create tables for for GG/GL/AN 
if ismember('GambleLoss', tmpTab.Properties.VariableNames)
    GL_tab = tmpTab(tmpTab.GambleLoss == 1, :); % Gamble loss

    for ei = 1:length(epochINT)

        if strcmpi('Start', epochINT{ei})
            GL_start = GL_tab(strcmp(GL_tab.EpochID, 'Start'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), GL_start.Ephys));

            for fi = 1:length(GL_start.Ephys)
                currentData = GL_start.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                GL_start.Ephys{fi} = currentData;
            end % for / fi
            % GL_start.Ephys{fi} = currentData;
            GLStartEphys = mean(cell2mat(GL_start.Ephys)');

            cleanedTabs.GLStart = GLStartEphys; % add data to struct

        elseif strcmpi('Decision', epochINT{ei})

            GL_dec = GL_tab(strcmp(GL_tab.EpochID, 'Decision'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), GL_dec.Ephys));

            for fi = 1:length(GL_dec.Ephys)
                currentData = GL_dec.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                GL_dec.Ephys{fi} = currentData;
            end % for / fi

            GLDecEphys = mean(cell2mat(GL_dec.Ephys)');

            cleanedTabs.GLDec = GLDecEphys; % add data to struct

        elseif strcmpi('Response', epochINT{ei})

            GL_res = GL_tab(strcmp(GL_tab.EpochID, 'Response'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), GL_res.Ephys));

            for fi = 1:length(GL_res.Ephys)
                currentData = GL_res.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                GL_res.Ephys{fi} = currentData;
            end % for / fi


            GLResEphys = mean(cell2mat(GL_res.Ephys)');

            cleanedTabs.GLRes = GLResEphys; % add data to struct


        elseif strcmpi('Outcome', epochINT{ei})

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

        else
            disp('your code is broke')

        end % if else / start / gamble loss

    end % for / ei / length of epochs

end % if / ismember

if ismember('GambleGain',tmpTab.Properties.VariableNames)
    GG_tab = tmpTab(tmpTab.GambleGain == 1, :);

    for ei = 1:length(epochINT)

        if strcmpi('Start', epochINT{ei})
            GG_start = GG_tab(strcmp(GG_tab.EpochID, 'Start'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), GG_start.Ephys));

            for fi = 1:length(GG_start.Ephys)
                currentData = GG_start.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                GG_start.Ephys{fi} = currentData;
            end % for / fi

            GGStartEphys = mean(cell2mat(GG_start.Ephys)');

            cleanedTabs.GGStart = GGStartEphys; % add data to struct

        elseif strcmpi('Decision', epochINT{ei})

            GG_dec = GG_tab(strcmp(GG_tab.EpochID, 'Decision'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), GG_dec.Ephys));

            for fi = 1:length(GG_dec.Ephys)
                currentData = GG_dec.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                GG_dec.Ephys{fi} = currentData;
            end % for / fi


            GGDecEphys = mean(cell2mat(GG_dec.Ephys)');

            cleanedTabs.GGDec = GGDecEphys; % add data to struct

        elseif strcmpi('Response', epochINT{ei})

            GG_res = GG_tab(strcmp(GG_tab.EpochID, 'Response'), :);

            % Remove columns that are longer than the minimum column
            minCols = min(cellfun(@(x) size(x, 2), GG_res.Ephys));

            for fi = 1:length(GG_res.Ephys)
                currentData = GG_res.Ephys{fi};
                if size(currentData,2) > minCols
                    % Remove columns that exceed minCols
                    currentData(:, minCols+1:end) = [];
                end % if else
                GG_res.Ephys{fi} = currentData;
            end % for / fi


            GGResEphys = mean(cell2mat(GG_res.Ephys)');

            cleanedTabs.GGRes = GGResEphys; % add data to struct

        elseif strcmpi('Outcome', epochINT{ei})

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
        else
            disp('your code is broke')

        end % if else / start / gamble loss

    end % for / ei / length of epochs

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

end % if else

end % function