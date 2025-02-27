%% 3 Brain areas - Start epoch - only gamble and alternative - no outcome

datasets = {epochEphys1.GamStart, epochEphys2.GamStart, epochEphys3.GamStart, ...
    epochEphys1.AltStart, epochEphys2.AltStart, epochEphys3.AltStart};
colors = {'green', 'blue','m', 'green', 'blue', 'm'};
% xOffsets = [-0.2, 0.2, 0.6, 1.2, 1.8, 2.2, 2.8, 3.2, 3.6]; % Adjust based on the number of datasets
xOffsets = [-0.6, -0.2, 0.2, 0.8, 1.2, 1.6, 2.4, 3.0, 3.4]; % Adjust based on the number of datasets

figure;
hold on

% Initialize a cell array to store y values
y_values = cell(1, length(datasets));
y_names = {'E1_Gamstart','E2_Gamstart', 'E3_Gamstart', 'E1_Altstart', 'E2_Altstart', ...
    'E3_Altstart'};

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
xticks(1:2)
% xticks([mean(xOffsets(1:3)), mean(xOffsets(4:6)), mean(xOffsets(7:9))])
xticklabels({'Gamble', 'Alternative'})

hold off

%%

yStats = [y_names; y_values]; % concatenate y values with variable names
%%
% Electrode 1 vs itself
[~, pval1] = kstest2(yStats{2,1}, yStats{2,4}) 
%%
% Electrode 2 vs itself
[~, pval1] = kstest2(yStats{2,2}, yStats{2,5})

%%
% Electrode 3 vs itself
[~, pval1] = kstest2(yStats{2,3}, yStats{2,6})

%%
% Electrode 1 vs itself
[~, pval1] = kstest2(yStats{2,2}, yStats{2,3})




