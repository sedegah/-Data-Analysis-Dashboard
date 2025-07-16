function dashboard()
    % DASHBOARD - Interactive Data Analysis Dashboard

    fig = uifigure('Name', 'Data Analysis Dashboard', 'Position', [100 100 950 550]);

    % Shared data
    data = [];

    % UI Components
    btnLoad = uibutton(fig, 'Text', 'Load CSV', ...
        'Position', [30 500 100 30], ...
        'ButtonPushedFcn', @(btn, event) loadData());

    lblX = uilabel(fig, 'Text', 'X Variable:', 'Position', [150 505 70 20]);
    dropdownX = uidropdown(fig, 'Position', [220 500 120 30]);

    lblY = uilabel(fig, 'Text', 'Y Variable:', 'Position', [360 505 70 20]);
    dropdownY = uidropdown(fig, 'Position', [430 500 120 30]);

    btnExport = uibutton(fig, 'Text', 'Export Plot as PNG', ...
        'Position', [580 500 150 30], ...
        'ButtonPushedFcn', @(btn, event) exportPlot());

    ax = uiaxes(fig, 'Position', [30 120 520 350]);
    ax.XGrid = 'on'; ax.YGrid = 'on';

    txtStats = uitextarea(fig, 'Position', [570 120 350 280], ...
        'Editable', 'off', 'FontSize', 12);

    btnScatter = uibutton(fig, 'Text', 'Scatter Plot', ...
        'Position', [580 420 150 30], ...
        'ButtonPushedFcn', @(btn, event) plotScatter());

    btnHist = uibutton(fig, 'Text', 'Histogram / Bar (X)', ...
        'Position', [580 380 150 30], ...
        'ButtonPushedFcn', @(btn, event) plotHistogram());

    btnBox = uibutton(fig, 'Text', 'Boxplot (X or X by Y)', ...
        'Position', [580 340 150 30], ...
        'ButtonPushedFcn', @(btn, event) plotBox());

    tbl = uitable(fig, 'Position', [30 10 890 90]);

    % --- Load CSV ---
    function loadData()
        [file, path] = uigetfile('*.csv');
        if isequal(file, 0), return; end
        fullPath = fullfile(path, file);
        try
            data = readtable(fullPath);
        catch
            uialert(fig, 'Failed to read CSV.', 'Load Error');
            return;
        end
        vars = data.Properties.VariableNames;
        dropdownX.Items = vars;
        dropdownY.Items = vars;
        txtStats.Value = {'CSV loaded. Select variables to visualize.'};
        tbl.Data = data;
    end

    % --- Scatter Plot ---
    function plotScatter()
        if isempty(data), return; end
        x = dropdownX.Value;
        y = dropdownY.Value;

        if ~isnumeric(data.(x)) || ~isnumeric(data.(y))
            uialert(fig, 'Both variables must be numeric.', 'Scatter Plot Error');
            return;
        end

        scatter(ax, data.(x), data.(y), 'filled');
        title(ax, sprintf('Scatter Plot: %s vs %s', y, x));
        xlabel(ax, x); ylabel(ax, y);
        updateStatsXY(x, y);
    end

    % --- Histogram or Bar Chart ---
    function plotHistogram()
        if isempty(data), return; end
        x = dropdownX.Value;

        cla(ax);

        if iscategorical(data.(x)) || isstring(data.(x)) || iscellstr(data.(x))
            valCounts = groupcounts(categorical(data.(x)));
            cats = categories(categorical(data.(x)));
            bar(ax, valCounts);
            xticks(ax, 1:length(cats));
            xticklabels(ax, cats);
            title(ax, sprintf('Bar Chart of %s', x));
            xlabel(ax, x); ylabel(ax, 'Count');
        elseif isnumeric(data.(x))
            histogram(ax, data.(x));
            title(ax, sprintf('Histogram of %s', x));
            xlabel(ax, x); ylabel(ax, 'Frequency');
        else
            uialert(fig, 'Unsupported variable type.', 'Histogram Error');
            return;
        end

        updateStats(x);
    end

    % --- Boxplot (with support for group-by Y) ---
    function plotBox()
        if isempty(data), return; end
        x = dropdownX.Value;
        y = dropdownY.Value;

        cla(ax);

        if isnumeric(data.(x)) && iscategorical(data.(y))
            boxplot(ax, data.(x), data.(y));
            title(ax, sprintf('Boxplot of %s by %s', x, y));
            xlabel(ax, y); ylabel(ax, x);
            updateStats(x);
        elseif isnumeric(data.(x))
            boxplot(ax, data.(x));
            title(ax, sprintf('Boxplot of %s', x));
            xlabel(ax, x);
            updateStats(x);
        else
            uialert(fig, 'X must be numeric. (Optional: Y can be categorical for grouping)', 'Boxplot Error');
        end
    end

    % --- Stats for one variable ---
    function updateStats(varName)
        vals = data.(varName);
        if isnumeric(vals)
            stats = {
                sprintf('Variable: %s', varName)
                sprintf('Mean: %.2f', mean(vals, 'omitnan'))
                sprintf('Median: %.2f', median(vals, 'omitnan'))
                sprintf('Std Dev: %.2f', std(vals, 'omitnan'))
                sprintf('Min: %.2f', min(vals, [], 'omitnan'))
                sprintf('Max: %.2f', max(vals, [], 'omitnan'))
                sprintf('Missing: %d', sum(ismissing(vals)))
            };
        else
            stats = {
                sprintf('Variable: %s (Categorical)', varName)
                sprintf('Num Categories: %d', numel(categories(categorical(vals))))
                sprintf('Missing: %d', sum(ismissing(vals)))
            };
        end
        txtStats.Value = stats;
    end

    % --- Stats for X and Y (Scatter) ---
    function updateStatsXY(x, y)
        valsX = data.(x);
        valsY = data.(y);
        stats = {
            sprintf('X Variable: %s', x)
            sprintf('  Mean: %.2f', mean(valsX, 'omitnan'))
            sprintf('  Std Dev: %.2f', std(valsX, 'omitnan'))
            sprintf('Y Variable: %s', y)
            sprintf('  Mean: %.2f', mean(valsY, 'omitnan'))
            sprintf('  Std Dev: %.2f', std(valsY, 'omitnan'))
            sprintf('Correlation: %.2f', corr(valsX, valsY, 'Rows', 'complete'))
        };
        txtStats.Value = stats;
    end

    % --- Export current plot as PNG ---
    function exportPlot()
        [file, path] = uiputfile('*.png', 'Save Plot As');
        if isequal(file, 0), return; end
        exportgraphics(ax, fullfile(path, file), 'Resolution', 300);
        uialert(fig, 'Plot saved successfully.', 'Export Complete');
    end
end